require_relative '../utils/couchdb'
require_relative '../target/panic'
require_relative '../utils/date'

#
# Performs transformation for hackathon status displayed on Panic borad
#
class Leaderboard
  attr_accessor :title
  attr_accessor :data

  DAY_HOUR   = 24
  WEEK_HOUR  = DAY_HOUR * 7
  MONTH_HOUR = DAY_HOUR * 30

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

  # Generates the leaderboard table
  def table html_template = nil
    event_hash = {}
    rows = []
    begin
      rows = @data["rows"]
    rescue
    end

    rows.each do |row|
      key = row["key"]
      value = row["value"]
      value["date"] = DateTime.iso8601(value["date"])

      list = event_hash[key] || []
      list << value
      event_hash[key] = list
    end

    now = DateTime.now

    Panic.generate_table html_template do |projects|
      event_hash.each_pair do |key, value|
        name, avatar_url = key.split(/\//, 2)
        user_evt = {
          "name" => name,
          "avatar_url" => avatar_url,
          "badges" => [CouchDB::BADGE_PLACEHOLDER_URL]
        }

        hour_array = Array.new(MONTH_HOUR, 0)
        value.each do |evt|
          hour = now - evt["date"] # start counting from 0
          hour_array[hour] += evt["count"] unless hour >= MONTH_HOUR  # discard activity before a month
        end

        hotness = 0.0

        weight_value = 1.25
        hour_array[0, WEEK_HOUR].each_with_index do |commit_count, idx|
          day = idx / DAY_HOUR
          initial = weight_value / (2 ** day)
          target = initial / 2
          slop = target / DAY_HOUR
          v = initial - slop * (idx % DAY_HOUR)
          hotness += commit_count * v
        end
        hotness = hotness.to_i

        hotness = 6 if hotness > 6                              # do not exceed 6, since we are adding 2 below
        hotness -= 1 unless hour_array[0] > 0                   # punish if the user is not committing this hour
        hotness = 0 if hotness < 0                              # not too much!
        hotness += 1 if hour_array.inject(:+) > 0               # has commit within this month, hotness plus 1
        hotness += 1 if hour_array[0, WEEK_HOUR].inject(:+) > 0 # has commit within this week, hotness plus 1
        hotness = 8 if hotness > 8                              # do not exceed the big limit

        user_evt["hotness"] = hotness

        projects << user_evt
      end

      projects.sort! {|first, second| second["hotness"] - first["hotness"] }
    end
  end

end
