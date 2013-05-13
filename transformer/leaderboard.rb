require_relative '../utils/couchdb'
require_relative '../target/panic'

#
# Performs transformation for hackathon status displayed on Panic borad
#
class Leaderboard
  attr_accessor :title
  attr_accessor :data

  def initialize title, json_obj
    @title = title
    @data = json_obj
  end

  # Generates the summary chart for panic status board from @data
  def chart
    score_hash = {}
    begin
      score_hash = @data["rows"][0]["value"]
    rescue # do nothing
    end

    colors = Panic::COLOR_ARRAY

    Panic.generate_chart @title do |data_seqs|
      score_hash.each_pair do |name, score|
        score_seq = {
          "title" => name,
          "color" => colors[name.sum % colors.length],
          "refreshEveryNSeconds" => 60
        }

        score_info = {
          "title" => "score",
          "value" => score
        }

        score_seq["datapoints"] = [score_info]
        data_seqs << score_seq
      end
    end
  end

end
