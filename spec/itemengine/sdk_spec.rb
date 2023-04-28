require "spec_helper"

RSpec.describe Itemengine::Sdk do
  it "has a version number" do
    expect(Itemengine::Sdk::VERSION).not_to be nil
  end
end
