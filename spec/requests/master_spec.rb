require 'rails_helper'

class MasterHelper

  def self.set_vars_and_params(objs)
    vars, params = {}.to_sh, {}.to_sh

    vars[:user] = new_user if objs.find{ |k, v| v == 'user' }

    objs.each do |id_type, name|
      
      class_name = name.to_s.camelize.constantize
      
      if class_name.new.attributes.include?("user_id")
        vars[name] = FactoryGirl.create(name, user: vars[:user] || new_user)
      elsif name != 'user'
        vars[name] = FactoryGirl.create(name)
      end
      params[id_type.to_sym] = vars[name].id
    end
    [vars, params]
  end

  def self.user(vars, role = :member)
    vars.user || vars.find{ |k, obj| obj[:user_id] }.try(:last).try(:user) || new_user(role)
  end

  def self.path(path, params)
    params.each{ |k, v| path.gsub!(":#{k}", v.to_s) }
    path
  end

  def self.new_user(role=:member)
    FactoryGirl.create(:user, role: role)
  end
end

describe "All views" do

  context "as admin" do
    it "renders or redirects all pages" do
      run_tests(role: :admin)
    end
  end

  context "as member" do
    context "who owns objects" do
      it "renders or redirects all pages" do
        run_tests(role: :member, context: 'as member who owns objects', owns_objects: true)
      end
    end

    context "who doesn't own objects" do
      it "renders or redirects all pages" do
        run_tests(role: :member, context: "as member who doesn't own objects", owns_objects: false)
      end
    end
  end

  context "as visitor" do
    it "renders or redirects all pages" do
      run_tests(role: :pending)
    end
  end

  def run_tests(role:, context: nil, owns_objects: false)

    context ||= "as #{role}"
    
    RouterHelper.get_routes_by_controller( %w(mini_scrape oauths allowable bookmarklets search point unmatched_route morph find_all_notes_in_plan find_by_object located_near add_nearby remove_nearby /admin/ geonames) ).each do |ctrl_group|
      ctrl_group.last.each do |rh|
        action = [rh.ctrl, rh.sub_path].join('#')
        vars, params = MasterHelper.set_vars_and_params(rh.required_objects.dup)

        if !owns_objects && role == :member && vars.map(&:last).any?{ |o| o.attributes.keys.include?("user_id")}
          new_user = MasterHelper.new_user
          vars.map(&:last).select{ |a| a.attributes.keys.include?("user_id") }.each{ |o| o.update_attributes!({user_id: new_user.id}) }
        end

        path = MasterHelper.path(rh.full_path.dup, params)
        user = MasterHelper.user(vars, role)
        assert_successful_render(action, context, user, path)
      end
    end
  end

  def assert_successful_render(action, context, user, path)
    sign_in user if user
    get path
    # report status, action, context
    expect( response ).to render_or_redirect(action, context)
  end

  def report(status, action, context)
    puts [lengthen(status).truncate(10, omission: ''), lengthen(action).truncate(40, omission: ''), context].join("\t")
  end

  def lengthen(string)
    "#{string}                                             "
  end
end