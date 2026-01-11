const User = require("../../../../models/User");

class MongoUserRepository {
  async findByEmail(email) {
    return User.findOne({ email: email.toLowerCase() });
  }

  async findByUsername(username) {
    return User.findOne({ username });
  }

  async findById(id) {
    return User.findById(id);
  }

  async create(data) {
    const doc = await User.create(data);
    return doc;
  }
  
  async updateById(id, data) {
    return User.findByIdAndUpdate(
      id,
      { $set: data },
      {
        new: true,          
        runValidators: true 
      }
    );
  }
}

module.exports = { MongoUserRepository };
