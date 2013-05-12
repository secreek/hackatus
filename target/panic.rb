#
# Panic status board
#
class Panic
  # Colors supported by panic board
  COLOR_ARRAY = [
    "yellow", "green", "red",
    "purple", "blue", "pink",
    "aqua", "orange", "lightGray"
  ]

  # returns generated json obj
  def self.generate_summary title
    summary = {
      "graph" => {
        "title" => title
      }
    }

    data_seqs = []
    yield(data_seqs) if block_given?

    # TODO make sure the data conforms to the protocol
    data_seqs.sort! do |first, second|
      second["datapoints"][0]["value"] - first["datapoints"][0]["value"]
    end

    summary["graph"]["datasequences"] = data_seqs
    summary
  end

end
