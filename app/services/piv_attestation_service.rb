class PivAttestationService
  def initialize(attestation_certificate, attestation_statement)
    @attestation_certificate = attestation_certificate
    @attestation_statement = attestation_statement
  end

  def perform_attestation(user)
    # YUBIKEY SERIAL PARSING
    serial = serial_parsed
    if !serial || serial.kind_of?(Array)
      return { error: "Failed to parse YubiKey serial number from the attestation statement" }, :bad_request
    end

    # SKIP VERIFICATION FOR EXTERNAL USERS [SEC-6030]
    skip_verification = skip_verification?(user)

    unless skip_verification
      # YUBIKEY SERIAL VERIFICATION
      username = serial_verified(serial)
      return { error: "The YubiKey with serial #{serial} was not found in inventory" }, :bad_request unless username

      # YUBIKEY HOLDER VERIFICATION
      return { error: "The YubiKey with serial #{serial} does not belong to #{user.displayname} as per inventory records" }, :bad_request if username.downcase != user.username.downcase
    end

    # KEY ATTESTATION. SSH key is extracted from the statement during attestation
    statement_public_key = key_attestated
    return { error: "Key attestation failed" }, :bad_request unless statement_public_key

    # CONVERTATION TO SSH FORMAT
    sshkey = key_converted(statement_public_key)

    if user.update(sshkey: sshkey)
      return { data: sshkey }, :accepted
    else
      return { error: 'Something went wrong' }, :bad_request
    end
  end

  private

  def serial_parsed
    begin
      certificate = OpenSSL::X509::Certificate.new @attestation_statement
      certificate.extensions.each do |extention|
        if extention.oid == "1.3.6.1.4.1.41482.3.7"
          asn1_object =  OpenSSL::ASN1.decode(extention).value
          asn1_octet_string =  asn1_object.second
          der = asn1_octet_string.to_der
          asn1_serial = OpenSSL::ASN1.decode(der)
          asn1_integer = OpenSSL::ASN1.decode(asn1_serial.value)
          serial = asn1_integer.value
          return serial
        end
      end
    rescue 
      return false
    end
  end

  def serial_verified(serial)
    begin
      filter = %Q|[{"operator": "eq", "value": "Yubico", "property": "vendor"}, {"operator": "eq", "value": "#{serial}", "property": "serial"}]|
      filter = filter.to_query("filter")
      url = URI.parse("https://#{ENV.fetch("INVENTORY_HOSTNAME")}/ajax/data.php?o=r&c=Equipment&start=0&limit=1&#{filter}")
      req = Net::HTTP::Get.new(url)
      req['Authorization'] = "Bearer #{ENV.fetch("INVENTORY_TOKEN")}"
      res = Net::HTTP.start(url.host, url.port, :use_ssl => true) {|http|
          http.request(req)
      }
      body = JSON.parse(res.body)
      username = body["data"].first["user"]["login"]

      if body["data"].first["state"] == "1" || body["data"].first["state"] == "2" # 1 = reserved, 2 = issued
        return username
      end
    rescue
      return false
    end
  end

  def skip_verification?(user)
    # Skip if user is an external user or VERIFY_YUBIKEY_SERIAL is explicitly set to "false"
    return true if user.dn.include?('OU=External Users')
    
    # Skip if either INVENTORY_HOSTNAME or INVENTORY_TOKEN is not set
    return true if ENV['INVENTORY_HOSTNAME'].nil? || ENV['INVENTORY_TOKEN'].nil?
  
    false
  end

  def key_attestated
    begin
      raw = File.read "piv-attestation-ca.pem"
      ca = OpenSSL::X509::Certificate.new raw
  
      certificate = OpenSSL::X509::Certificate.new @attestation_certificate
  
      statement = OpenSSL::X509::Certificate.new @attestation_statement
  
      certificate_verified = certificate.verify(ca.public_key) && (certificate.issuer.to_s == ca.subject.to_s) && (certificate != ca)
      statement_verified = statement.verify(certificate.public_key) && (statement.issuer.to_s == certificate.subject.to_s)

      return statement.public_key if certificate_verified && statement_verified
    rescue 
      return false
    end
  end

  def key_converted(statement_public_key)
    type = statement_public_key.ssh_type
    data = [ statement_public_key.to_blob ].pack('m0')
    openssh_format = "#{type} #{data}"

    return openssh_format
  end

end