require "net/http"

class Speak_in
  GOOGLE_TRANSLATE_URL = "http://translate.google.com/translate_tts".freeze
  attr_accessor :text, :lang

  def initialize(text, lang="pt-br")
    @text = text
    @lang = lang
  end

  def self.load(file_path, lang = "en")
    f = File.open(file_path)
    new f.read.encode("UTF-16be", invalid: :replace, replace: "?").encode("UTF-8"), lang
	end

  # Toca, Tem possibilidade de colocar o local onde vai tocar
  def play(path = "temp.wav")
    system("mpg123 #{path}")
  end

  # Salva, Tem possibilidade de colocar o local onde vai salvar
  def save(file_path = "temp.wav")
    uri = URI(GOOGLE_TRANSLATE_URL)

    response = []

    sentences = text.split(/[,.\r\n]/i)
    sentences.reject!(&:empty?)
    sentences.map! { |t| divide(t.strip) }.flatten!

    sentences.each_with_index do |q, _idx|
    uri.query = URI.encode_www_form(
    ie: "UTF-8",
    q: q,
    tl: lang,
    total: sentences.length,
    idx: 0,
    textlen: q.length,
    client: "tw-ob",
    prev: "input"
		)

		res = Net::HTTP.get_response(uri)

		next unless res.is_a?(Net::HTTPSuccess)

		response << res.body.force_encoding(Encoding::UTF_8)
    end

    if @path
      File.open(file_path, "wb") do |f|
        f.write response.join
        return f.path
        end
    else
      File.open(file_path, "wb") do |f|
      f.write response.join
      return f.path
      end
    end
	end

  private

	def divide(text)
	  return text if text.length < 150

	  attempts = text.length / 150.0
	  starts = 0
	  arr = []

	  attempts.ceil.times do
		ends = starts + 150
		arr << text[starts...ends]
		starts = ends
	  end

	  arr
	end
end
