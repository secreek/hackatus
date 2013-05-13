require 'sinatra'
require 'sinatra/namespace'
require 'json'

require_relative 'utils/github'
require_relative 'utils/couchdb'
require_relative 'transformer/hackathon'
require_relative 'transformer/leaderboard'
require_relative 'target/panic'

# Hackatus for Hackathon
namespace '/hackathon' do
  get '/chart.json' do
    title, obj = parse_params params

    # Set file typ eo application/json
    response.headers["Content-Type"] = "application/json"

    # generates data
    hackathon = Hackathon.new title, obj
    hackathon.chart.to_json
  end

  get '/table.html' do
    title, obj = parse_params params {|is_hackathon| 2 if is_hackathon  }
    hackathon = Hackathon.new title, obj
    hackathon.table(open("template/hackathon_table.html.erb").read)
  end

  get '/table.json' do
    title, obj = parse_params params {|is_hackathon| 2 if is_hackathon  }
    hackathon = Hackathon.new title, obj
    hackathon.table.to_json
  end

  private
  def parse_params params
    hackathon = false
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
      hackathon = true;
    end

    since = yield(hackathon) if block_given?
    since ||= 24  # default to 24 hours

    obj["since"] ||= since.hours_ago # default to 24 hours ago

    [title, obj]
  end
end


# Hackatus for Leaderboard
namespace '/leaderboard' do
  get '/chart.json' do
    # Set file typ eo application/json
    response.headers["Content-Type"] = "application/json"

    title = "Screek Leaderboard"
    obj = CouchDB.score_board
    leaderboard = Leaderboard.new title, obj
    leaderboard.chart.to_json
  end

  get '/table.html' do
    title = "Screek Leaderboard"
    obj = CouchDB.activity_history
    hackathon = Leaderboard.new title, obj
    hackathon.table(open("template/leaderboard_table.html.erb").read)
  end

  get '/table.json' do
    title = "Screek Leaderboard"
    obj = CouchDB.activity_history
    hackathon = Leaderboard.new title, obj
    hackathon.table.to_json
  end
end






