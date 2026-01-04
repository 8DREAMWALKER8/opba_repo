const { UserEntity } = require("../../domain/UserEntity"); // path sende doğru olan

class UpdateUser {
  constructor({ userRepo, hasher }) {
    this.userRepo = userRepo;
    this.hasher = hasher;
  }

  async execute({ userId, data }) {
    if (!userId) throw new Error("userId is required");
    if (!data || typeof data !== "object") throw new Error("data is required");

    const current = await this.userRepo.findById(userId);
    if (!current) throw new Error("User not found");

    // ✅ phone eklendi
    const allowed = [
      "username",
      "email",
      "phone",
      "password",
      "currentPassword",
      "securityQuestionId",
      "securityAnswer",
      "newAnswer",
    ];

    const patch = {};
    for (const k of allowed) {
      if (data[k] !== undefined) patch[k] = data[k];
    }

    if (Object.keys(patch).length === 0) {
      return new UserEntity({
        id: current.id || current._id?.toString(),
        username: current.username,
        email: current.email,
        passwordHash: current.passwordHash,
        securityQuestionId: current.securityQuestionId,
        securityAnswerHash: current.securityAnswerHash,
        createdAt: current.createdAt,
        updatedAt: current.updatedAt,
      });
    }

    const updateData = {};

    if (patch.username !== undefined) updateData.username = String(patch.username);

    if (patch.email !== undefined) {
      updateData.email = String(patch.email).toLowerCase();
    }

    // ✅ phone update + basit doğrulama
    if (patch.phone !== undefined) {
      const phone = String(patch.phone).trim();
      if (!/^\d{10,15}$/.test(phone)) {
        throw new Error("phone must be digits (10-15)");
      }
      updateData.phone = phone;
    }
    console.log("Patch data for update:", patch);
    if (patch.password !== undefined) {
        
      updateData.passwordHash = await this.hasher.hash(String(patch.password));
      const ok = await this.hasher.compare(String(patch.currentPassword), current.passwordHash);

      if (updateData.passwordHash === current.passwordHash) {
        throw new Error("New password must be different from the current password");
      }

      if (!ok) {
        throw new Error("Current password is incorrect");
      }
    }


    if (patch.securityAnswer !== undefined && patch.newAnswer !== undefined && patch.newAnswer !== null) {

        const ok = await this.hasher.compare(String(patch.securityAnswer), current.securityAnswerHash);

        if (!ok) {
            throw new Error("Current security answer is incorrect");
        }

        if (patch.securityQuestionId !== undefined) {
            updateData.securityQuestionId = String(patch.securityQuestionId);
        }

        updateData.securityAnswerHash = await this.hasher.hash(String(patch.newAnswer));
    }

    updateData.updatedAt = new Date();

    const updated = await this.userRepo.updateById(userId, updateData);
    if (!updated) throw new Error("User not found");
    console.log("Updated user data:", updated);
    return new UserEntity({
      id: updated.id || updated._id?.toString(),
      username: updated.username,
      email: updated.email,
      phone: updated.phone,
      passwordHash: updated.passwordHash,
      securityQuestionId: updated.securityQuestionId,
      securityAnswerHash: updated.securityAnswerHash,
      createdAt: updated.createdAt,
      updatedAt: updated.updatedAt,
    });
  }
}

module.exports = { UpdateUser };