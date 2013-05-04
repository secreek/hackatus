require 'json'
require './network_utils'
require 'open-uri'
require 'nokogiri'

class Github
  include NetworkUtils
  PERIODS = ['day','week','month']

  def self.prepare_gh_key_pair
    params = {
      "client_id" => ENV["GH_KEY_PAIR_ID"],
      "client_secret" => ENV["GH_KEY_PAIR_SECRET"]
    }

    params
  end

  def self.commits repo_path, since
    commits_uri = "https://api.github.com/repos/#{repo_path}/commits"
    puts commits_uri
    params = self.prepare_gh_key_pair
    params["since"] = since
    commits = NetworkUtils.do_request_returning_json(commits_uri, params)
    commits ||= []
    commits
  end

  def self.commit_count repo_path, since
    commits = self.commits(repo_path, since)
    return 0 unless commits
    commits.length
  end

  # Getting Trending Repos by period
  def self.trendsof period

    return false unless PERIODS.include?(period)

    uri = "https://github.com/explore/#{period}"

    doc = Nokogiri::HTML(open(uri))
    elements = doc.xpath("//h2[contains(.,'Trending Repos')]/following-sibling::ol/li/h3")
    repos = elements.map { |element| element.xpath('a').children.map { |text| text.to_s } }

  end
end
