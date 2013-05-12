require 'sinatra'
require 'json'

require_relative 'utils/github'
require_relative 'transformer/hackathon'
require_relative 'target/panic'

get '/summary.json' do
  obj = {}
  title = ""
  case params["type"]
  when "explore"
    period = params["period"]
    period = "day" unless Github.valid_period? period
    obj["repos"] = Github.explore period
    title = "Trending of the #{period.capitalize}"
  else
    obj = JSON.load(open('config.json').read)
    title = "Hackathon Status"
  end
  obj["since"] ||= 24.hours_ago # default to 24 hours ago

  # Set file typ eo application/json
  response.headers["Content-Type"] = "application/json"

  # generates data
  hackathon = Hackathon.new title, obj
  hackathon.summary
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
