class NetTest
  require 'timeout'
  require 'socket'

  def self.dns
    begin
      %x{cat /etc/resolv.conf | grep nameserver | awk '{print $2}'}.each do |nameserver|
        Timeout::timeout(2) do
          if nameserver.strip! =~ /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/
            Resolv::DNS.new({:nameserver => nameserver}).getaddress("www.google.fr")
          end
        end
      end
      true
    rescue Timeout::Error
      false
    end
  end

  def self.http
    begin
      Timeout::timeout(2) do
        %x{/usr/bin/nc -z www.google.fr 80; echo $?}.to_i.zero?
      end
    rescue Timeout::Error
      false
    end
  end

  def self.https
    begin
      Timeout::timeout(2) do
        %x{/usr/bin/nc -z www.google.fr 443; echo $?}.to_i.zero?
      end
    rescue Timeout::Error
      false
    end
  end

end
