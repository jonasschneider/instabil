require File.expand_path(File.dirname(__FILE__)+'/../spec_helper')

describe "Message" do
  let(:me) { Person.create! name: 'Jonas' do |p| p.uid = 'schneijo'; end }
  
  let(:message) { Message.create! author: me, body: 'Hi!' }
  
  describe "#client_attributes" do
    it "works" do
      message.client_attributes.should == { author: 'Jonas', created_at: message.created_at.strftime('%H:%M'), body: 'Hi!' }
    end
    
    it "strips tags" do
      message.body = 'test <b>ohai</b>'
      message.client_attributes[:body].should == 'test &lt;b&gt;ohai&lt;/b&gt;'
    end
  end
  
  it "is capped" do
    200.times do
      Message.create! author: me, body: 'Hi!'
    end
    Message.count.should == Message::CAP
  end
end