require 'json'
require './network_utils'

class Github
  include NetworkUtils

  def self.prepare_gh_key_pair
    params = {
      "client_id" => ENV["GH_KEY_PAIR_ID"],
      "client_secret" => ENV["GH_KEY_PAIR_SECRET"]
    }

    params
  end

  def self.commits repo_path, since
    commits_uri = "https://api.github.com/repos/#{repo_path}/commits?since=#{since}"
    params = self.prepare_gh_key_pair
    NetworkUtils.do_request_returning_json(commits_uri, params)
  end

  def self.commit_count repo_path, since
    self.commits(repo_path, since).length
  end

end
