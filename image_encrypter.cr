require "openssl/cipher"

filename = ARGV[0]?

unless filename 
  puts "please enter base filename" 
  puts "crystal image_encrypter.cr superman.bmp"
  exit 1
end

filename = filename.split(".").first

basefile = File.read("#{filename}.bmp").to_slice

headers = basefile[0, 54]
data = basefile[54, basefile.size - 54]

def simple_enc(data : Bytes, secret : Bytes) : Bytes
  data.map_with_index{|b, i| b ^ secret[i%secret.size]}
end

def encrypt(value : Bytes, alg = "aes-256-cbc", secret = "much_password") : Bytes
  cipher = OpenSSL::Cipher.new(alg)
  cipher.encrypt
  cipher.key = secret + (0..32-secret.size).join("")
  iv = cipher.random_iv

  encrypted_data = IO::Memory.new
  encrypted_data.write(cipher.update(value))
  encrypted_data.write(cipher.final)
  encrypted_data.to_slice
end

File.open("#{filename}_simple.bmp", "w") do |f|
  f.write headers
  f.write simple_enc(data, "much password so secret".to_slice)
end

File.open("#{filename}_ecb.bmp", "w") do |f|
  f.write headers
  f.write encrypt(data, "aes-256-ecb", "much password so secret")
end

File.open("#{filename}_cbc.bmp", "w") do |f|
  f.write headers
  f.write encrypt(data, "aes-256-cbc", "much password so secret")
end

File.open("#{filename}_ctr.bmp", "w") do |f|
  f.write headers
  f.write encrypt(data, "aes-256-ctr", "much password so secret")
end
