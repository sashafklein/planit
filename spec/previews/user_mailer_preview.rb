class UserMailerPreview < ActionMailer::Preview

  def welcome_waitlist
    UserMailer.welcome_waitlist( User.first )
  end

  def welcome_invited
    UserMailer.welcome_invited( User.first )
  end

  def share_love_user_guides
    url = "https://plan.it/users/" + User.first.slug + "/guides?y=in_2015"
    object = User.first
    new_share = Share.create(sharer: User.first, sharee: User.last, url: url, object: object, notes: "Hey this is awesome!")
    title = Share.build_title( object, Share.extras_hash(url) )
    UserMailer.share_love(share: new_share, title: title)
  end

  def share_love_user_places
    url = "https://plan.it/users/" + User.first.slug + "/places?f=food+drink"
    object = User.first
    new_share = Share.create(sharer: User.first, sharee: User.last, url: url, object: object, notes: "Hey this is awesome!")
    title = Share.build_title( object, Share.extras_hash(url) )
    UserMailer.share_love(share: new_share, title: title)
  end

  def share_love_plan
    url = "https://plan.it/plans/" + Plan.first.slug + "?q=tokyo+tea+time"
    object = Plan.first
    new_share = Share.create(sharer: User.first, sharee: User.last, url: url, object: object, notes: "Hey this is awesome!")
    title = Share.build_title( object, Share.extras_hash(url) )
    UserMailer.share_love(share: new_share, title: title)
  end

end