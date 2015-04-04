require 'rails_helper'

RSpec.describe "Routing to customers", type: :routing do
  it "routes GET /customers to customers#index" do
    expect(get: "/customers").to route_to(
      controller: "customers",
      action: "index"
    )
  end

#   it "routes GET /cats/:id to cats#show" do
#     expect(get: "/cats/1").to route_to(
#       controller: "cats",
#       action: "show",
#       id: "1"
#     )
#   end

#   it "routes GET /cats/:id/edit to cats#edit" do
#     expect(get: "/cats/1/edit").to route_to(
#       controller: "cats",
#       action: "edit",
#       id: "1"
#     )
#   end

#   it "routes PATCH /cats/:id to cats#update for cat" do
#     expect(patch: "/cats/1").to route_to(
#       controller: "cats",
#       action: "update",
#       id: "1"
#     )
#   end
end
