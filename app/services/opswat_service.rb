require "net/http"
require "uri"
require "json"

class OpswatService

  BASE_URL = "https://api.metadefender.com/v4"

  def initialize
    @api_key = ENV.fetch("OPSWAT_API_KEY")
  end

  def upload_file(file)

    uri = URI("#{BASE_URL}/file")

    request = Net::HTTP::Post.new(uri)

    request["apikey"] = @api_key
    request["rule"] = "multiscan,sanitize"
    request["filename"] = file.original_filename
    request["Content-Type"] = file.content_type

    request.body = File.binread(file.tempfile.path)

    response = Net::HTTP.start(
      uri.hostname,
      uri.port,
      use_ssl: true
    ) do |http|
      http.request(request)
    end

    Rails.logger.info "========== OPSWAT UPLOAD =========="
    Rails.logger.info "HTTP STATUS: #{response.code}"
    Rails.logger.info "RESPONSE: #{response.body}"
    Rails.logger.info "==================================="

    unless response.is_a?(Net::HTTPSuccess)
      raise "OPSWAT upload failed: #{response.code} #{response.body}"
    end

    JSON.parse(response.body)
  end


  def get_result(data_id)

    uri = URI("#{BASE_URL}/file/#{data_id}")

    request = Net::HTTP::Get.new(uri)

    request["apikey"] = @api_key

    response = Net::HTTP.start(
      uri.hostname,
      uri.port,
      use_ssl: true
    ) do |http|
      http.request(request)
    end

    Rails.logger.info "========== OPSWAT RESULT =========="
    Rails.logger.info "HTTP STATUS: #{response.code}"
    Rails.logger.info "RESPONSE: #{response.body}"
    Rails.logger.info "==================================="

    unless response.is_a?(Net::HTTPSuccess)
      raise "OPSWAT result failed: #{response.code} #{response.body}"
    end

    JSON.parse(response.body)
  end


  def scan_and_sanitize(file)

    upload_result = upload_file(file)

    data_id = upload_result["data_id"]

    if data_id.blank?
      raise "OPSWAT did not return data_id. Response: #{upload_result}"
    end

    Rails.logger.info "OPSWAT DATA ID: #{data_id}"


    60.times do |attempt|

      sleep 2

      result = get_result(data_id)

      process_info =
        result["process_info"] || {}

      progress =
        process_info["progress_percentage"].to_i

      Rails.logger.info(
        "OPSWAT ATTEMPT #{attempt + 1}: #{progress}%"
      )

      if progress >= 100

        Rails.logger.info(
          "========== OPSWAT COMPLETED =========="
        )

        Rails.logger.info(
          JSON.pretty_generate(result)
        )

        Rails.logger.info(
          "======================================"
        )

        return {
          data_id: data_id,
          result: result
        }

      end

    end

    raise "OPSWAT scan timeout"

  end


  def download_sanitized_file(data_id)

    uri =
      URI(
        "#{BASE_URL}/file/converted/#{data_id}"
      )

    request =
      Net::HTTP::Get.new(uri)

    request["apikey"] = @api_key

    response =
      Net::HTTP.start(
        uri.hostname,
        uri.port,
        use_ssl: true
      ) do |http|
        http.request(request)
      end

    Rails.logger.info(
      "OPSWAT SANITIZED DOWNLOAD STATUS: #{response.code}"
    )

    unless response.is_a?(Net::HTTPSuccess)

      raise(
        "OPSWAT sanitized download failed: " \
        "#{response.code} #{response.body}"
      )

    end

    response.body
  end

end