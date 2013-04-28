require 'sinatra'
require 'json'

require './github'
require './datehelper'

get '/summary.json' do
  response.headers["Content-Type"] = "application/json"

  color_array = ["yellow", "green", "red", "purple", "blue", "mediumGray", "pink", "aqua", "orange", "lightGray"]
  random = Random.new
  random_color = color_array[random.rand color_array.length]

  summary = {
    "graph" => {
      "title" => "Hackathon Status"
    }
  }

  data_seqs = []
  commit_seq = {
    "title" => "commits",
    "color" => random_color,
    "refreshEveryNSeconds" => 60
  }

  commit_summary = []
  obj = JSON.load(open('config.json').read)
  since = obj["since"]
  obj["repos"].each_with_index do |repo, idx|
    commit_info = {
      "title" => repo["name"],
      "value" => Github.commit_count(repo["path"], since)
    }
    commit_summary << commit_info
  end

  commit_summary.sort! do |first, second|
    puts second
    puts first
    second["value"] - first["value"]
  end
  commit_seq["datapoints"] = commit_summary
  data_seqs << commit_seq

  summary["graph"]["datasequences"] = data_seqs
  summary.to_json
end

get '/table.html' do
  html_erb = ERB::new(open("table.html.erb").read)
  obj = JSON.load(open('config.json').read)
  @projects = []
  @since = (DateTime.now - 1.hours).strftime("%FT%RZ")
  obj["repos"].each do |repo|
    proj_info = {
      "name" => repo["name"]
    }
    members = []
    commits = Github.commits repo["path"], @since
    commits ||= []
    commits.each do |commit|
      next unless commit["author"]
      member = {
        "name" => commit["author"]["login"],
        "avatar_url" => commit["author"]["avatar_url"]
      }
      members << member unless members.include? member
    end
    proj_info["members"] = members

    commit_count = commits.length
    proj_info["commit_count"] = commit_count
    proj_info["commit_bar_count"] = commit_count
    proj_info["commit_bar_count"] = 8 if (commit_count > 8)
    @projects << proj_info
  end

  @projects.sort! {|first, second| second["commit_count"] - first["commit_count"] }
  html_erb.result(binding)
end
