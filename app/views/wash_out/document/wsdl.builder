xml.instruct!
xml.tag! "wsdl:definitions", 
          "xmlns:wsdl" => 'http://schemas.xmlsoap.org/wsdl/','xmlns:tns' => @namespace,
          'xmlns:soap' => 'http://schemas.xmlsoap.org/wsdl/soap/',
          'xmlns:xsd' => 'http://www.w3.org/2001/XMLSchema',
          'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
          'xmlns:soap-enc' => 'http://schemas.xmlsoap.org/soap/encoding/',
          'name' => @name,
          "xmlns:plnk"=>"http://schemas.xmlsoap.org/ws/2003/05/partner-link/",
          'targetNamespace' => @namespace do
  xml.tag! "wsdl:documentation", "xmlns:oer" => "http://xmlns.oracle.com/oer"  do
    xml.name @name
    xml.description "Sample WSDL"
    xml.tag! "oer:lifecycle", "Active"
    @map.each do |operation, formats|
      xml.tag! "oer:operation", "name"=>operation do
        xml.description "Sample Operation"
      end   
    end
  end


  xml.tag! "plnk:partnerLinkType", :name => "pdhsoap_service" do
    xml.tag! "plnk:role", :name => "pdhsoap_service_provider" do
      xml.tag! "plnk:portType", :name => "tns:pdhsoap_service"
    end
  end



  xml.tag! "wsdl:types" do
    xml.tag! "schema", :targetNamespace => @namespace, :xmlns => 'http://www.w3.org/2001/XMLSchema' do
      defined = []
      @map.each do |operation, formats|
        (formats[:in] + formats[:out]).each do |p|
          wsdl_type xml, p, defined
        end
      end
    end
  end

  @map.each do |operation, formats|
    xml.message :name => "#{operation}" do
      formats[:in].each do |p|
        xml.part wsdl_occurence(p, false, :name => p.name, :type => p.namespaced_type)
      end
    end
    xml.message :name => formats[:response_tag] do
      formats[:out].each do |p|
        xml.part wsdl_occurence(p, false, :name => p.name, :type => p.namespaced_type)
      end
    end
  end

  xml.tag! "wsdl:portType",  :name => "#{@name}_port" do
    @map.each do |operation, formats|
      xml.tag! "wsdl:operation", :name => operation do
        xml.tag! "wsdl:input", :message  => "tns:#{operation}"
        xml.tag! "wsdl:output", :message => "tns:#{formats[:response_tag]}"
      end
    end
  end

  xml.tag! "wsdl:binding", :name => "#{@name}_binding", :type => "tns:#{@name}_port" do
    xml.tag! "soap:binding", :style => 'document', :transport => 'http://schemas.xmlsoap.org/soap/http'
    @map.keys.each do |operation|
      xml.tag! "wsdl:operation", :name => operation do
        xml.tag! "soap:operation", :soapAction => operation
        xml.tag! "wsdl:input" do
          xml.tag! "soap:body",
            :use => "literal",
            :namespace => @namespace
        end
        xml.tag! "wsdl:output" do
          xml.tag! "soap:body",
            :use => "literal",
            :namespace => @namespace
        end
      end
    end
  end

  xml.tag! "wsdl:service", :name => "service" do
    xml.tag! "wsdl:port", :name => "#{@name}_port", :binding => "tns:#{@name}_binding" do
      xml.tag! "soap:address", :location => WashOut::Router.url(request, @name)
    end
  end
end
