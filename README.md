# Introduction

**Aurita** is a decentralized lending optimizer built on top of lending pools like Aries or Echelon. It enhances capital efficiency by matching lenders and borrowers peer-to-peer, offering improved interest rates.

# Testnet Deployment
**Aurita Contract**
```bash
0x29c7c0182d3cd3f4b12e57eee7cd6653194828a3535745229eeae8b861253067
```

**Aurita Coin**
```bash
0x9ecc4f0af6934c425dfd8c83f34cc8895bc1b82bd1b3adccfdb416ecff697675
```

# Compile

```bash
aptos move compile
```

# Test

```bash
aptos move test
```

# Add as dependency

Add to `Move.toml`

```toml
[dependencies.MorphoAptos]
git = "https://github.com/BuckyFinance/aurita.git"
rev = "<commit hash>"
```
And then use in code:

```rust
use account::entry_positions_manager;
...
lending_pool::supply
```

# LICENSE
MIT.
