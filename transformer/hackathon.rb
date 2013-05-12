require_relative '../utils/github'
require_relative '../target/panic'

#
# Performs transformation for hackathon status displayed on Panic borad
#
class Hackathon
  attr_accessor :title
  attr_accessor :data
  attr_reader   :github

  def initialize title, json_obj
    @title = title
    @data = json_obj
    @github = Github.new

    raise "error: missing repo list" unless @data.include? "repos"
    raise "error: missing since time" unless @data.include? "since"
  end

  # Generates the summary for panic status board from @data
  def summary
    repos = @data["repos"]
    since = @data["since"]
    colors = Panic::COLOR_ARRAY

    Panic.generate_summary @title do |data_seqs|
      repos.each_with_index do |repo, idx|
        commit_seq = {
          "title" => repo["name"],
          "color" => colors[idx % colors.length],
          "refreshEveryNSeconds" => 60
        }

        commits = github.commits repo["path"], since

        # grab first committer's avater
        # Not included in standard Panic Status Board protocol
        # Reserved for hailong's implementation
        portait = "";
        begin
          portait = commits[0]["author"]["avatar_url"]
        rescue Exception
          portait = "https://secure.gravatar.com/avatar/8ecf5ff215d7f209af859eacdd1cb1f2?s=420&d=https://a248.e.akamai.net/assets.github.com%2Fimages%2Fgravatars%2Fgravatar-user-420.png"
        end

        commit_info = {
          "title" => "commits",
          "value" => commits.length,
          "portait" => portait
        }

        commit_seq["datapoints"] = [commit_info]
        data_seqs << commit_seq
      end
    end
  end
end
