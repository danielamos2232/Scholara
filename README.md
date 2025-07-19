# 🎓 Scholara - Scholarship DAO

> **Community-funded student sponsorships through decentralized governance**

Scholara is a decentralized autonomous organization (DAO) built on Stacks that enables community members to collectively fund student scholarships through transparent voting mechanisms.

## ✨ Features

- 💰 **Community Contributions**: Members contribute STX to fund scholarships
- 📝 **Student Applications**: Students can submit detailed scholarship applications
- 🗳️ **Proposal Voting**: Weighted voting based on contribution amounts
- 🎯 **Transparent Execution**: Automatic scholarship distribution upon approval
- 👥 **Governance Controls**: Adjustable parameters for voting periods and requirements

## 🚀 How It Works

### For Contributors
1. **Contribute STX** to the DAO treasury
2. **Vote on proposals** with voting power proportional to contributions
3. **Participate in governance** decisions

### For Students
1. **Submit application** with academic and financial information
2. **Wait for proposal creation** by community members
3. **Receive funding** if proposal passes community vote

### For Proposal Creators
1. **Create proposals** for deserving students
2. **Set scholarship amounts** and descriptions
3. **Monitor voting progress** during voting period

## 📋 Contract Functions

### Public Functions

| Function | Description |
|----------|-------------|
| `contribute` | Add STX to DAO treasury and gain voting power |
| `submit-application` | Students submit scholarship applications |
| `create-proposal` | Create funding proposal for a student |
| `vote-on-proposal` | Vote for/against proposals (weighted by contribution) |
| `execute-proposal` | Execute approved proposals after voting period |
| `cancel-proposal` | Cancel active proposals (owner/student only) |

### Admin Functions

| Function | Description |
|----------|-------------|
| `update-voting-period` | Modify voting duration (blocks) |
| `update-min-proposal-amount` | Set minimum scholarship amount |
| `update-min-votes-required` | Adjust minimum votes for execution |

### Read-Only Functions

| Function | Description |
|----------|-------------|
| `get-proposal` | Retrieve proposal details |
| `get-vote` | Check specific vote information |
| `get-member-contribution` | View member's total contributions |
| `get-student-application` | Access student application data |
| `get-contract-balance` | Current DAO treasury balance |
| `get-proposal-status` | Comprehensive proposal status |

## 🛠️ Usage Examples

### Contributing to the DAO
```clarity
(contract-call? .scholarship-dao contribute)
```

### Submitting Student Application
```clarity
(contract-call? .scholarship-dao submit-application 
  "Alice Johnson" 
  "State University" 
  "Computer Science" 
  u385 
  "First-generation college student with financial hardship")
```

### Creating Scholarship Proposal
```clarity
(contract-call? .scholarship-dao create-proposal 
  'ST1STUDENT123... 
  u5000000 
  "Scholarship for outstanding CS student Alice Johnson")
```

### Voting on Proposal
```clarity
(contract-call? .scholarship-dao vote-on-proposal u1 true)
```

### Executing Approved Proposal
```clarity
(contract-call? .scholarship-dao execute-proposal u1)
```

## ⚙️ Configuration

- **Minimum Proposal Amount**: 1,000,000 µSTX (1 STX)
- **Voting Period**: 1,440 blocks (~10 days)
- **Minimum Votes Required**: 3 weighted votes

## 🔒 Security Features

- ✅ Contribution-weighted voting prevents spam
- ✅ Time-locked voting periods ensure fair participation  
- ✅ Proposal expiration prevents indefinite pending states
- ✅ Double-voting protection
- ✅ Owner controls for parameter adjustments

## 🏗️ Development

Built with:
- **Clarity** smart contract language
- **Stacks** blockchain
- **Clarinet** development framework

## 📄 License

MIT License - see LICENSE file for details

---

*Empowering education through decentralized funding* 🌟

