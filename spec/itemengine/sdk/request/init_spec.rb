require "spec_helper"

RSpec.describe Itemengine::Sdk::Request::Init do
  before(:all) do
    Itemengine::Sdk::Request::Init.disable_telemetry
  end

  after(:all) do
    Itemengine::Sdk::Request::Init.enable_telemetry
  end

  securityPacket = {
    "consumerKey" => "pX9aLcW8dV7jK2bN",
    "domain" => "localhost",
    "timestamp" => "20140626-0528",
  }
  consumerSecret = "4c6e0b0d6895116f72d6c46cf6f214ed6d63b6bc"

  itemsRequest = {
    "userId" => "$ANONYMIZED_USER_ID",
    "rendering_type" => "assess",
    "name" => "Items API demo - assess activity demo",
    "state" => "initial",
    "activity_id" => "items_assess_demo",
    "session_id" => "demo_session_uuid",
    "type" => "submit_practice",
    "config" => {
      "configuration" => {
        "responsive_regions" => true,
      },
      "navigation" => {
        "scrolling_indicator" => true,
      },
      "regions" => "main",
      "time" => {
        "show_pause" => true,
        "max_time" => 300,
      },
      "title" => "ItemsAPI Assess Isolation Demo",
      "subtitle" => "Testing Subtitle Text",
    },
    "items" => [
      "Demo3",
    ],
  }

  context "validation" do
    it "throws ValidationException on missing service" do
      expect {
        Itemengine::Sdk::Request::Init.new(nil, securityPacket, consumerSecret)
      }.to raise_exception Itemengine::Sdk::ValidationException, /service.*empty/
    end

    it "throws ValidationException on invalid service" do
      expect {
        Itemengine::Sdk::Request::Init.new("invalid service", securityPacket, consumerSecret)
      }.to raise_exception Itemengine::Sdk::ValidationException, /service.*not valid/
    end

    it "throws ValidationException on missing securityPacket" do
      expect {
        Itemengine::Sdk::Request::Init.new("items", nil, consumerSecret)
      }.to raise_exception Itemengine::Sdk::ValidationException, /security packet.*Hash/
    end

    it "throws ValidationException on non-hash securityPacket" do
      expect {
        Itemengine::Sdk::Request::Init.new("items", "not a hash", consumerSecret)
      }.to raise_exception Itemengine::Sdk::ValidationException, /security packet.*Hash/
    end

    it "throws ValidationException on unexpected key in securityPacket" do
      local_security_packet = securityPacket.clone
      local_security_packet["notASecurityKey"] = "atAll"
      expect {
        Itemengine::Sdk::Request::Init.new("items", local_security_packet, consumerSecret)
      }.to raise_exception Itemengine::Sdk::ValidationException, /Invalid key.*security packet/
    end

    it "throws ValidationException on missing secret" do
      expect {
        Itemengine::Sdk::Request::Init.new("items", securityPacket, nil)
      }.to raise_exception Itemengine::Sdk::ValidationException, /secret.*string/
    end

    it "throws ValidationException on invalid secret" do
      expect {
        Itemengine::Sdk::Request::Init.new("items", securityPacket, { :notAString => 42 })
      }.to raise_exception Itemengine::Sdk::ValidationException, /secret.*string/
    end

    it "throws ValidationException on non-hash request" do
      expect {
        Itemengine::Sdk::Request::Init.new("items", securityPacket, consumerSecret, "notAHash")
      }.to raise_exception Itemengine::Sdk::ValidationException, /request packet.*hash/
    end

    it "throws ValidationException on non-string action" do
      expect {
        Itemengine::Sdk::Request::Init.new("items", securityPacket, consumerSecret, itemsRequest, { :notAString => 42 })
      }.to raise_exception Itemengine::Sdk::ValidationException, /action.*string/
    end

    it "should add a timestamp to the authentication packet if missing" do
      local_security_packet = securityPacket.clone
      local_security_packet.delete("timestamp")
      init = Itemengine::Sdk::Request::Init.new("items", local_security_packet, consumerSecret)
      expect(init.securityPacket).to have_key("timestamp")
    end

    it "should not raise exceptions with well-formed arguments" do
      expect {
        Itemengine::Sdk::Request::Init.new("items", securityPacket, consumerSecret, itemsRequest, "get")
      }.to_not raise_exception
    end
  end

  context "Author API" do
    authorRequest = {
      "mode" => "item_list",
      "config" => {
        "item_list" => {
          "item" => {
            "status" => true,
          },
        },
      },
      "user" => {
        "id" => "walterwhite",
        "firstname" => "walter",
        "lastname" => "white",
      },
    }

    it "can generate signature" do
      init = Itemengine::Sdk::Request::Init.new(
        "author",
        securityPacket,
        consumerSecret,
        authorRequest
      )
      expect(init.generateSignature).to eq("9511a0a7deafdd77dbb7c08ac1f1b6ecf469814c9f83374b7d8bfd732f9ad558")
    end

    it "can generate init options" do
      init = Itemengine::Sdk::Request::Init.new(
        "author",
        securityPacket,
        consumerSecret,
        authorRequest
      )
      expect(init.generate(true)).to eq('{"authentication":{"consumerKey":"pX9aLcW8dV7jK2bN","domain":"localhost","timestamp":"20140626-0528","signature":"9511a0a7deafdd77dbb7c08ac1f1b6ecf469814c9f83374b7d8bfd732f9ad558"},"request":{"mode":"item_list","config":{"item_list":{"item":{"status":true}}},"user":{"id":"walterwhite","firstname":"walter","lastname":"white"}}}')
    end
  end

  context "Data API" do
    dataRequest = { "limit" => 100 }

    it "can generate signature for GET" do
      init = Itemengine::Sdk::Request::Init.new(
        "data",
        securityPacket,
        consumerSecret,
        dataRequest,
        "get"
      )
      expect(init.generateSignature).to eq("5c399563d275edf379bbcc7c6ed4ed78160b42ec3e5cf4ffb81665b034e4f3c5")
    end

    it "can generate signature for POST" do
      init = Itemengine::Sdk::Request::Init.new(
        "data",
        securityPacket,
        consumerSecret,
        dataRequest,
        "post"
      )
      expect(init.generateSignature).to eq("2fd47bd9b7c33bcb1909ee790988369dc8676544417f2a418eeeaf09ec922279")
    end

    it "can generate signature for GET with expiry" do
      dataExpiresSecurityPacket = securityPacket.clone
      dataExpiresSecurityPacket["expires"] = "20160621-1716"

      init = Itemengine::Sdk::Request::Init.new(
        "data",
        dataExpiresSecurityPacket,
        consumerSecret,
        dataRequest,
        "get"
      )
      expect(init.generateSignature).to eq("70f743e2f347961398ebe7f6ada5c928881ec9d2c02e3cc9f6cfa77c3f059b06")
    end

    it "can generate init options for GET" do
      init = Itemengine::Sdk::Request::Init.new(
        "data",
        securityPacket,
        consumerSecret,
        dataRequest,
        "get"
      )
      expect(init.generate).to eq(
        {
          "authentication" => '{"consumerKey":"pX9aLcW8dV7jK2bN","domain":"localhost","timestamp":"20140626-0528","signature":"5c399563d275edf379bbcc7c6ed4ed78160b42ec3e5cf4ffb81665b034e4f3c5"}',
          "request" => '{"limit":100}',
          "action" => "get",
        }
      )
    end

    it "can generate init options for POST" do
      init = Itemengine::Sdk::Request::Init.new(
        "data",
        securityPacket,
        consumerSecret,
        dataRequest,
        "post"
      )
      expect(init.generate).to eq(
        {
          "authentication" => '{"consumerKey":"pX9aLcW8dV7jK2bN","domain":"localhost","timestamp":"20140626-0528","signature":"2fd47bd9b7c33bcb1909ee790988369dc8676544417f2a418eeeaf09ec922279"}',
          "request" => '{"limit":100}',
          "action" => "post",
        }
      )
    end
  end

  context "Items API" do
    it "copies userId from request to authentication packet if present" do
      init = Itemengine::Sdk::Request::Init.new(
        "items",
        securityPacket,
        consumerSecret,
        itemsRequest
      )
      expect(init.securityPacket).to have_key("userId")
    end

    it "can generate signature" do
      init = Itemengine::Sdk::Request::Init.new(
        "items",
        securityPacket,
        consumerSecret,
        itemsRequest
      )

      expect(init.generateSignature).to eq("8b8e809dc11f006faf204767296b8350d1050c3d197406c26385b80ef6424332")
    end

    it "can generate init options" do
      init = Itemengine::Sdk::Request::Init.new(
        "items",
        securityPacket,
        consumerSecret,
        itemsRequest
      )

      expect(init.generate).to eq('{"authentication":{"consumerKey":"pX9aLcW8dV7jK2bN","domain":"localhost","timestamp":"20140626-0528","userId":"$ANONYMIZED_USER_ID","signature":"8b8e809dc11f006faf204767296b8350d1050c3d197406c26385b80ef6424332"},"request":{"userId":"$ANONYMIZED_USER_ID","rendering_type":"assess","name":"Items API demo - assess activity demo","state":"initial","activity_id":"items_assess_demo","session_id":"demo_session_uuid","type":"submit_practice","config":{"configuration":{"responsive_regions":true},"navigation":{"scrolling_indicator":true},"regions":"main","time":{"show_pause":true,"max_time":300},"title":"ItemsAPI Assess Isolation Demo","subtitle":"Testing Subtitle Text"},"items":["Demo3"]}}')
    end
  end
end

# vim: sw=2
