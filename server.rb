require 'sinatra'
require 'json'

require './github'
require './datehelper'
require './network_utils'

def explore_json
  content = NetworkUtils.do_request 'https://github.com/explore'

  repo_list = []
  content.each_line do |line|
    if match = /\ \/\ <a href=\"\/(.+)\/(.+)\"/.match(line)
      content = {}
      owner, name = match.captures
      content["name"] = name
      content["path"] = owner + "/" + name
      repo_list << content
    end
  end

  repo_list
end

get '/summary.json' do
  response.headers["Content-Type"] = "application/json"

  color_array = ["yellow", "green", "red", "purple", "blue", "pink", "aqua", "orange", "lightGray"]

  summary = {
    "graph" => {
      "title" => "Hackathon Status"
    }
  }

  data_seqs = []

  obj = {}
  if params["explore"] == "true"
    obj["repos"] = explore_json
  else
    obj = JSON.load(open('config.json').read)
  end

  since = obj["since"]
  since ||= 24.hours_ago # change to 24 hours

  obj["repos"].each_with_index do |repo, idx|
    commit_summary = []
    commit_seq = {
      "title" => repo["name"],
      "color" => color_array[idx % color_array.length],
      "refreshEveryNSeconds" => 60
    }
    commits = Github.commits(repo["path"], since)

    portait = "";
    begin
      portait = commits[0]["author"]["avatar_url"]
    rescue Exception => e
      portait = "https://secure.gravatar.com/avatar/8ecf5ff215d7f209af859eacdd1cb1f2?s=420&d=https://a248.e.akamai.net/assets.github.com%2Fimages%2Fgravatars%2Fgravatar-user-420.png"
    end

    commit_info = {
      "title" => "commits",
      "value" => commits.length,
      "portait" => portait
    }
    commit_summary << commit_info
    commit_seq["datapoints"] = commit_summary
    data_seqs << commit_seq
  end

  data_seqs.sort! do |first, second|
    second["datapoints"][0]["value"] - first["datapoints"][0]["value"]
  end

  summary["graph"]["datasequences"] = data_seqs
  summary.to_json
end

get '/table.html' do
  html_erb = ERB::new(open("table.html.erb").read)
  fill_table_json
  html_erb.result(binding)
end

get '/table.json' do
  fill_table_json.to_json
end

def fill_table_json
  obj = {}
  if params["explore"] == "true"
    obj["repos"] = explore_json
  else
    obj = JSON.load(open('config.json').read)
    @since = 2.hours_ago
  end

  @projects = []

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

  @projects
end
