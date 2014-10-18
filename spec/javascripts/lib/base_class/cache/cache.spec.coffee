describe 'BCCache', ->
  it "adds a cache to the model", ->
    expect(Post.cached).toBeDefined
    expect(Post.cached.cache).toBeDefined
    expect(Object.keys(Post.cached).length).toBe(0)
    
  it "adds new instances to the cache when they are created", ->
    post = Post.new({id: 1})
    expect(Post.cached[1]).toEqual(post)

  it "finds via search parameters", ->
    post = Post.new({id: 1})
    expect( Post.cached.where({id: 1}) ).toEqual[post]

  it 'is empty if it contains no instances', ->
    expect( Post.cached.isEmpty() ).toEqual(true)

  it 'is not empty if it contains instances', ->
    post = Post.new({id: 1})
    expect( Post.cached.isEmpty() ).toEqual(false)

  it "finds via search parameters", ->
    post = Post.new({id: 1})
    expect( Post.cached.where({id: 1}) ).toEqual([post])