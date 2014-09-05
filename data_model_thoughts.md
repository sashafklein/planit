## My Tentative Data Model

The more I think about this, the more I think this would (mostly) work.

#### Plan
- title
- user_id
- start_date
- end_date
- duration (days)
- description
- notes (do we want user-specific notes? I think that'd be cool, but definitely not MVP)
- permissions (public/private/mixed -- I envision mixed as allowing users to determine what non-collaborators see. Maybe that would cost money?)

#### Moneyshot
- url
- plan_id
- order

#### Leg
- name
- bucket (true/false)
- order
- notes
- optional attrs for potentially faster calculation:
> Those might include `length`

#### Travel (referred to as arrival/departure)
- mode (car/flight/boat/etc)
- origin (location or full-fledged item)
- destination (location or full-fledged item)
- arrival_time
- departure_time
- vessel_number/name
- confirmation
- next_step_id (for multi-leg flights, etc)
- notes

#### Day
- leg_id
- order
- notes

#### Item
- leg_id (usually redundant, but not with bucket)
- day_id (with a bucket, you could still set this)
- location_id
- image
- show_image
- lodging
- duration
- notes
- arrival_id (travel object -- can be shared)
- departure_id (travel object -- can be shared)
> I'm thinking we just do special behavior if the travel is between a leg or a day, fundamentally, it's always between "items" (or, in one case, between Travels)

#### Location
- name
- local_name
- address
- lat
- lon
- website
- source
- source_url
- genre (restaurant/cafe/site/hotel)
- subgenre (Spanish, hostel, monument)


----------------------------------------------


### Thoughts

- We may want to think about a PlatonicItem, or BaseItem -- a single, canonical, shared object for an Item (say Fuunji Ramen) with a constantly updated set of information (duration, newest address, image, etc). An item on an itinerary would be based off of that, but could be alterered. When someone wanted to add something, we'd search our DB first, then Foursquare, Google Places, etc.

- I think this model would work really well, but it doesn't pay any attention to time of day, yet. Our `duration` column could fix this, but maybe that's not the best solution.

- I'm eliding certain things. Namely, the whole user side of the equation. We'll want Users who can be owners, collaborators, or just viewers.


### Questions

#### What do you mean by: 

- The output section of your notes: 
> "Play-by-play / Minute-by-minute -- for consumer, not guide/leader"
> "Data-rich / maps & full-info -- for leader/navigator/guide"

- "Even if all travel points/objects hidden, display overlay (o)--> w/ time?"

- "Tour guide-wrapped objects, details on guide
Different travellers & their travel plans + master plan == confirmations, times for flights, etc, days of the trip they’re a part of"

- This:

"Food
See
Stay
Tips"


#### Other questions/thoughts: 

"Prominence of the event / attractiveness of the photo? "
> So do you think we should allow users to mark items as big/medium/small? We could change the show_image field to an image_size field, with "none" as an option.


"Honeymoon feature -- price tags, leave a note, add a spot"
> Well, I'm adding note fields to everything, but we could spruce things up with time

"Alternatives / branching of plans -- overlap days/times of day -- chose which to do?"
> I'd punt on this for now. Seems pretty tough. Why can't people just make multiple plans?

"Bucket items sit as alternative/addition but optionally tagged to day/time of day?"
> I think the above model would support this.
Pre-planned vs. On -the-road