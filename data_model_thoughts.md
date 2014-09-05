## My Tentative Data Model

The more I think about this, the more I think this would (mostly) work.

#### Plan
- title
- user_id
- start_date (of trip)
- end_date (of trip)
- duration (days)
- description
- notes (do we want user-specific notes? I think that'd be cool, but definitely not MVP)
- permissions (public/private/mixed -- I envision mixed as allowing users to determine what non-collaborators see. Maybe that would cost money?)
* rating
* - [0]
*   - author_id
*   - overall rating
*   - date rated
* - [1...etc]
*   - user_id
*   - overall rating
*   - date rated
* 
* unique id (hash)
* - [0]
*   - current_id
*   - begun_date (as a file)
*   [1...etc]
*   - input id (i.e. an itinerary that's been shared into this one and used)
*   - input date (i.e. the date it was shared/merged)

*#### Moneyshot <-- can we just make this a tag in the overall gallery?  e.g.. for any photo of size > 1260x500, allow a tag of "make moneyshot" -- then you can auto-import image credits, caption, etc
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
* terminals
* carrier/company
* cost (for all items, not just travel?)
* 

#### Day
- leg_id
- order
- notes

#### Item
- leg_id (usually redundant, but not with bucket)
- day_id (with a bucket, you could still set this)
- location_id
* image (array)
* - [0]
*   - caption
*   - credit
*   - tab_size
*   - medium_size
*   - moneyshot/full_size
*   - order
*   - moneyshot true/false
* show_tab??
- lodging
- meal
- official (visa/ticket/etc?)
- duration
- notes
- arrival_id (travel object -- can be shared)
- departure_id (travel object -- can be shared)
> I'm thinking we just do special behavior if the travel is between a leg or a day, fundamentally, it's always between "items" (or, in one case, between Travels)
* i'd keep time of day as an optional

#### Location
- name
- local_name
- address
- lat
- lon
- website
- sources (array/hash)
* - [0]
*   - name
*   - url
*   - api'd? yes/no?
*   [1+ etc]
- genre (restaurant/cafe/site/hotel)
- subgenre (Spanish, hostel, monument)
-


----------------------------------------------


### Thoughts

- We may want to think about a PlatonicItem, or BaseItem -- a single, canonical, shared object for an Item (say Fuunji Ramen) with a constantly updated set of information (duration, newest address, image, etc). An item on an itinerary would be based off of that, but could be alterered. When someone wanted to add something, we'd search our DB first, then Foursquare, Google Places, etc. I LOVE THE IDEA OF THIS -- AND WE COULD KEEP CLEAN WITH A LAT/LON CROSS-COMPARISON + CHARACTER ANALYSIS -- BUT FOR THE TIME BEING, I'D JUST KEEP DUPLICATE LOCATIONS_ID'S ETC -- WE CAN FIGURE OUT HOW TO FORCE INTO CONSISTENT CHANNELS...

- I think this model would work really well, but it doesn't pay any attention to time of day, yet. Our `duration` column could fix this, but maybe that's not the best solution. LET'S ADD BACK TIME OF DAY AND DURATION -- BUT/AND BUILD A SIMPLE VISUAL TO GET US 90% THERE -- THAT IS,
- IF ROWS == 1, THE BASIC DAY ICON
- IF ROWS == 2, START WITH MORNING ICON, 2ND ROW AFTERNOON ICON
- IF ROWS == 3, MORNING / AFTERNOON / EVENING
- IF ROWS == 4, MORNING / NOON / AFTERNOON / EVENING ETC

- I'm eliding certain things. Namely, the whole user side of the equation. We'll want Users who can be owners, collaborators, or just viewers.
- YUP


### Questions

#### What do you mean by: 

- The output section of your notes: 
> "Play-by-play / Minute-by-minute -- for consumer, not guide/leader" SEE https://docs.google.com/document/d/1oUh8KRu6qGyVgw76kVcQ8I1Hx9aSnyl7mJMjYou4I8A/edit
> "Data-rich / maps & full-info -- for leader/navigator/guide" = what we have now in "print"

- "Even if all travel points/objects hidden, display overlay (o)--> w/ time?" -- I'm developing this now, sent you my wishful code -- the soft side (visuals) is built in & ready

- "Tour guide-wrapped objects, details on guide --- E.G. MARK A SECTION AS A KENJI-GUIDED SECTION, LINK TO HIM??
Different travellers & their travel plans + master plan == confirmations, times for flights, etc, days of the trip they’re a part of" E.G. MOM AND DAD ARRIVED 2 DAYS LATER THAN WE DID, LEFT A DAY BEFORE US, ETC -- IMPORTANT FEATURE I THINK -- AND WE COULD EASILY GENERATE PRINTABLE/APPABLE VERSIONS FOR EACH PERSON IF WE BUILT IN THIS DATA

- This:

"Food
See
Stay
Tips"


#### Other questions/thoughts: 

"Prominence of the event / attractiveness of the photo? "
> So do you think we should allow users to mark items as big/medium/small? We could change the show_image field to an image_size field, with "none" as an option. I SAY WE AUTO-ID SIZE, AND THEN LET RATINGS DRIVE PROMINENCE? HARD TO KNOW


"Honeymoon feature -- price tags, leave a note, add a spot"
> Well, I'm adding note fields to everything, but we could spruce things up with time -- THIS WOULD PROBABLY BE A SPECIALIZED NOTE -- LIKE A REGISTRY OR SOMETHING

"Alternatives / branching of plans -- overlap days/times of day -- chose which to do?"
> I'd punt on this for now. Seems pretty tough. Why can't people just make multiple plans? DUDE OK LET'S COME BACK BEFORE TOO LONG -- THIS IS HUGE -- IT'S ALSO TIED TO WHAT BRANDON WAS TALKING ABOUT RE- "FIXED" DATES/EVENTS ETC

"Bucket items sit as alternative/addition but optionally tagged to day/time of day?"
> I think the above model would support this.
Pre-planned vs. On -the-road
