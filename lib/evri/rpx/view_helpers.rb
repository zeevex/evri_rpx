require "cgi"

#
# Temporarily cribbed from rpx_now plugin by rsanders
#
module Evri::RPX
  module ViewHelpers

    def rpx_embed_code(subdomain, url, options = {})
      namespace = options.delete(:namespace)
      namespace += "_" if namespace.present? && namespace[-1,1] != "_"
      optstring = options.merge({:token_url => url}).map {|k,v| CGI.escape(k.to_s) + "=" + CGI.escape(v.to_s) }.join("&")

<<EOF
<script type="text/javascript">
function rpx_dismiss_progress(id) {
   jQuery('#' + id).hide();
}
</script>

<div id="#{namespace}rpx_embed_container" style="width:400px;height:240px; position:relative;">
  <div id="#{namespace}rpx_spinner" style="position:absolute; left: 150px; top: 100px; display: none;">
    <img src="/images/spinner.gif" height="16" width="16"> Loading...
  </div>

<script type="text/javascript">
jQuery('#{namespace}rpx_spinner').show();
</script>

<iframe id="#{namespace}rpx_embed" src="https://#{subdomain}.#{Evri::RPX::HOST}/openid/embed?#{optstring}" onload="rpx_dismiss_progress('#{namespace}rpx_spinner')"
  scrolling="no" frameBorder="no" style="width:400px;height:240px;">
</iframe>


</div>
EOF
    end  

    def rpx_popup_code(text, subdomain, url, options = {})
      if options[:unobtrusive]
        unobtrusive_popup_code(text, subdomain, url, options)
      else
        obtrusive_popup_code(text, subdomain, url, options)
      end
    end

    def rpx_embed_url(subdomain, url, options = {})
      optstring = options.merge({:token_url => url}).map {|k,v| CGI.escape(k.to_s) + "=" + CGI.escape(v.to_s) }.join("&")
      "https://#{subdomain}.#{Evri::RPX::HOST}/openid/embed?#{optstring}"
    end

  private

    def unobtrusive_popup_code(text, subdomain, url, options={})
      version = extract_version! options
      optstring = options.merge({:token_url => url}).map {|k,v| CGI.escape(k.to_s) + "=" + CGI.escape(v.to_s) }.join("&")

      "<a class=\"rpxnow\" href=\"https://#{subdomain}.#{Evri::RPX::HOST}/openid/v#{version}/signin?#{optstring}\">#{text}</a>"
    end

    def obtrusive_popup_code(text, subdomain, url, options = {})
      version = extract_version! options
      optstring = options.merge({:token_url => url}).map {|k,v| CGI.escape(k.to_s) + "=" + CGI.escape(v.to_s) }.join("&")

      <<EOF
<a class="rpxnow" onclick="return false;" href="https://#{subdomain}.#{HOST}/openid/v#{version}/signin?#{optstring}">
  #{text}
</a>
<script src="https://#{Evri::RPX::HOST}/openid/v#{version}/widget" type="text/javascript"></script>
<script type="text/javascript">
  //<![CDATA[
  RPXNOW.token_url = "#{url}";

  RPXNOW.realm = "#{subdomain}";
  RPXNOW.overlay = true;
  RPXNOW.language_preference = '#{options[:language]||'en'}';
  //]]>
</script>
EOF
    end

    def extract_key_version_and_options!(args)
      key, options = extract_key_and_options(args)
      version = extract_version! options
      [key, version, options]
    end

    # [API_KEY,{options}] or
    # [{options}] or
    # []
    def extract_key_and_options(args)
      if args.length == 2
        [args[0],args[1]]
      elsif args.length==1
        if args[0].is_a? Hash then [Evri::RPX.api_key,args[0]] else [args[0],{}] end
      else
        raise "NO Api Key found!" unless Evri::RPX.api_key
        [Evri::RPX.api_key,{}]
      end
    end

    def extract_version!(options)
      options.delete(:api_version) || Evri::RPX.api_version
    end

  end
end
