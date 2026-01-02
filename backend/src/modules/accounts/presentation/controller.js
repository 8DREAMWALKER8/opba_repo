module.exports = ({ listAccounts, createAccount, deactivateAccount }) => ({
  list: async (req, res) => {
    const userId = req.user.userId || req.user._id || req.user.id;
    const accounts = await listAccounts.execute({ userId });
    res.json({ ok: true, accounts });
  },

  create: async (req, res) => {
    const userId = req.user.userId || req.user._id || req.user.id;
    const account = await createAccount.execute({ userId, data: req.body });
    res.status(201).json({ ok: true, account });
  },

  deactivate: async (req, res) => {
    const userId = req.user.userId || req.user._id || req.user.id;
    const { id } = req.params;
    const account = await deactivateAccount.execute({ userId, accountId: id });
    res.json({ ok: true, account });
  },
});
