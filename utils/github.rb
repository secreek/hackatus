require_relative './network'
require_relative './date'

# A wrapper class for Github API v3.
#
# Usage:
#     github = Github.new
#     commits = github.commits 'secreek/GvS', 10.hours_ago
#
class Github
  include NetworkUtils

  GITHUB_API_ENDPOINT = "https://api.github.com"

  attr_accessor :client_id
  attr_accessor :client_secret

  #---------------
  # public methods
  #---------------
  public

  # Prepare API-related stuff
  def initialize
    @client_id = ENV["GH_KEY_PAIR_ID"]
    @client_secret = ENV["GH_KEY_PAIR_SECRET"]
  end

  # Get commit info for repo (in the format of owner/name)
  def commits repo_path, since = 48.hours_ago
    request do |params|
      commits_uri = "#{GITHUB_API_ENDPOINT}/repos/#{repo_path}/commits"
      params["since"] = since
      NetworkUtils.do_request_returning_json(commits_uri, params)
    end
  end

  #----------------
  # private methods
  #----------------
  private

  # Prepare Github API key for request
  def request
    params = {
      "client_id" => @client_id,
      "client_secret" => @client_secret
    }

    result = yield(params) if block_given?

    result ||= [] # Keep safe
  end

  #--------------
  # Class methods
  #--------------
  public

  @@POSSBLE_PERIPD = ["day", "week", "month"]

  # Gets the repo list from `explore` of github in json format
  def self.explore period = "" # default = day
    content = NetworkUtils.do_request "https://github.com/explore/#{period}"

    repo_list = []
    content.each_line do |line|
      if match = /\ \/\ <a href=\"\/(.+)\/(.+)\"/.match(line)
        owner, name = match.captures
        repo_list << { "name" => name, "path" => owner + "/" + name }
      end
    end
    repo_list
  end

  def self.valid_period? period
    @@POSSBLE_PERIPD.include? period
  end

end
