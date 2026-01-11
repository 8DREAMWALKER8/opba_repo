// Users modülünü ayağa kaldıran ana dosya

const buildRoutes = require("./http/user.routes");
const { UserController } = require("./http/user.controller");

const { MongoUserRepository } = require("./infrastructure/repositories/MongoUserRepository");
const { PasswordHasher } = require("./infrastructure/security/PasswordHasher");
const { TokenService } = require("./infrastructure/security/TokenService");

const { RegisterUser } = require("./application/usecases/RegisterUser");
const { LoginStep1 } = require("./application/usecases/LoginStep1");
const { LoginStep2 } = require("./application/usecases/LoginStep2");
const { GetMe } = require("./application/usecases/GetMe");
const { UpdateUser } = require("./application/usecases/UpdateUser");

function buildUserModule() {
  const userRepo = new MongoUserRepository();
  const hasher = new PasswordHasher();
  const tokenService = new TokenService();

  const registerUser = new RegisterUser({ userRepo, hasher });
  const loginStep1 = new LoginStep1({ userRepo, hasher });
  const loginStep2 = new LoginStep2({ userRepo, hasher, tokenService });
  const getMe = new GetMe({ userRepo });
  const updateUser = new UpdateUser({ userRepo, hasher });

  const controller = new UserController({ registerUser, loginStep1, loginStep2, getMe, updateUser });
  const router = buildRoutes({ controller });

  return router;
}

module.exports = { buildUserModule };
