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

  def self.commit_count repo_name, since
    user_uri = "https://api.github.com/repos/#{repo_name}/commits?since=#{since}"
    params = self.prepare_gh_key_pair
    return NetworkUtils.do_request_returning_json(user_uri, params).length
  end

end
