require 'sinatra'
require 'json'
require './github'

get '/summary.json' do
  response.headers["Content-Type"] = "application/json"

  summary = {
    "title" => "Hackathon Status",
    "refreshEveryNSeconds" => 60
  }
  commit_summary = []
  obj = JSON.load(open('config.json').read)
  since = obj["since"]
  obj["repos"].each do |repo|
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
  summary["datapoints"] = commit_summary
  summary.to_json
end
