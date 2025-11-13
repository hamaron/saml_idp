require 'spec_helper'
module SamlIdp
  describe NameIdFormatter do
    subject { described_class.new list }

    describe "with one item" do
      let(:list) { { email_address: ->() { "foo@example.com" } } }

      it "has a valid all" do
        expect(subject.all).to eq ["urn:oasis:names:tc:SAML:2.0:nameid-format:emailAddress"]
      end

    end

    describe "with hash describing versions" do
      let(:list) {
        {
          "1.1" => { email_address: -> {} },
          "2.0" => { undefined: -> {} },
        }
      }

      it "has a valid all" do
        expect(subject.all).to eq [
          "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress",
          "urn:oasis:names:tc:SAML:2.0:nameid-format:undefined",
        ]
      end
    end

    describe "with actual list" do
      let(:list) { [:email_address, :undefined] }

      it "has a valid all" do
        expect(subject.all).to eq [
          "urn:oasis:names:tc:SAML:2.0:nameid-format:emailAddress",
          "urn:oasis:names:tc:SAML:2.0:nameid-format:undefined",
        ]
      end
    end

    describe "with literal urns" do
      context "when a getter is provided" do
        let(:literal) { "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress" }
        let(:list) { { literal => ->(_) { "foo@example.com" } } }

        it "returns the literal value unchanged" do
          expect(subject.all).to eq [literal]
        end
      end

      context "when no getter is provided" do
        let(:literal) { "urn:oasis:names:tc:SAML:2.0:nameid-format:persistent" }
        let(:list) { [literal] }

        it "derives a getter that matches the urn suffix" do
          getter = subject.chosen[:getter]
          principal = Struct.new(:persistent).new("abc")
          expect(getter.call(principal)).to eq "abc"
        end
      end
    end
  end
end
