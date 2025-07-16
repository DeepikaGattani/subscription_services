# Subscription Service

A decentralized subscription service built on blockchain technology using Solidity smart contracts and Hardhat framework.

## Project Description

The Subscription Service is a smart contract-based platform that enables businesses to offer subscription-based services with automated billing, transparent pricing, and decentralized management. Users can subscribe to various plans, manage their subscriptions, and make payments directly through the blockchain without intermediaries.

The system eliminates the need for traditional payment processors and provides a trustless environment where subscription terms are enforced by smart contracts. All transactions are transparent, immutable, and executed automatically according to predefined rules.

## Project Vision

To revolutionize the subscription economy by providing a decentralized, transparent, and automated subscription management system that empowers both service providers and consumers. Our vision is to create a world where subscription services are more accessible, affordable, and trustworthy through blockchain technology.

We aim to:
- Eliminate intermediaries and reduce transaction costs
- Provide transparent and immutable subscription records
- Enable global access to subscription services
- Create a trustless environment for recurring payments
- Foster innovation in the subscription economy

## Key Features

### Core Functionality
- **Subscription Plan Management**: Create and manage multiple subscription plans with different pricing and durations
- **Automated Renewals**: Smart contract-based automatic subscription renewals
- **Flexible Payment System**: Support for various payment methods and cryptocurrencies

### User Management
- **Easy Subscription**: Simple one-click subscription process
- **Subscription Tracking**: Real-time subscription status monitoring
- **Cancel Anytime**: Users can cancel subscriptions at any time

### Admin Features
- **Revenue Tracking**: Built-in analytics for total revenue and subscription metrics
- **Plan Management**: Create, modify, and deactivate subscription plans
- **Fund Withdrawal**: Secure withdrawal of collected subscription fees

### Security & Transparency
- **Ownership Controls**: Multi-signature wallet support for enhanced security
- **Transparent Pricing**: All pricing and terms are stored on-chain
- **Immutable Records**: All subscription history is permanently recorded

### Technical Features
- **Gas Optimization**: Efficient smart contract design to minimize transaction costs
- **Event Logging**: Comprehensive event system for tracking all activities
- **Modular Design**: Extensible architecture for future enhancements

## Future Scope

### Short-term Enhancements (3-6 months)
- **Multi-token Support**: Accept various ERC-20 tokens for subscriptions
- **Discount Coupons**: Implement promotional codes and discount systems
- **Subscription Tiers**: Multiple access levels within single subscription plans
- **Mobile App Integration**: React Native app for mobile subscription management

### Medium-term Developments (6-12 months)
- **DAO Integration**: Decentralized governance for platform decisions
- **NFT Subscriptions**: Subscription plans as tradeable NFTs
- **Cross-chain Support**: Multi-blockchain compatibility (Polygon, BSC, Ethereum)
- **Advanced Analytics**: Comprehensive dashboard for subscription analytics

### Long-term Vision (1-2 years)
- **Marketplace Integration**: Connect with existing e-commerce platforms
- **AI-powered Recommendations**: Intelligent subscription plan suggestions
- **Global Expansion**: Multi-language and multi-currency support
- **Enterprise Solutions**: Custom subscription solutions for large organizations

### Advanced Features
- **Subscription Gifting**: Allow users to gift subscriptions to others
- **Loyalty Programs**: Reward long-term subscribers with tokens or NFTs
- **Subscription Bundling**: Package multiple services together
- **Automated Compliance**: Built-in tax reporting and regulatory compliance

## Getting Started

### Prerequisites
- Node.js (v16 or higher)
- npm or yarn
- Git

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd subscription-service
```

2. Install dependencies:
```bash
npm install
```

3. Configure environment variables:
```bash
cp .env.example .env
# Edit .env with your configuration
```

4. Compile the contracts:
```bash
npm run compile
```

5. Deploy to Core Testnet 2:
```bash
npm run deploy
```

### Testing

Run the test suite:
```bash
npm run test
```

### Deployment

Deploy to Core Testnet 2:
```bash
npm run deploy
```

The contract will be deployed to the Core Testnet 2 network using the configured RPC endpoint.

## Contract Functions

### Core Functions

1. **createSubscriptionPlan**: Create new subscription plans (Owner only)
2. **subscribe**: Subscribe to a plan by paying the required amount
3. **renewSubscription**: Renew existing subscription with payment

### Utility Functions
- `isSubscriptionActive`: Check if a user's subscription is active
- `getUserSubscription`: Get user's subscription details
- `getSubscriptionPlan`: Get plan details
- `withdrawFunds`: Withdraw collected fees (Owner only)

## Contributing

We welcome contributions to the Subscription Service project. Please read our contributing guidelines and submit pull requests for any improvements.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions, please open an issue in the GitHub repository or contact the development team.

---

**Built with ❤️ using Solidity and Hardhat**
Transaction Hash:  0x7fc007ae6a8f4c16eae80eb3c221610b5baca5db4b12077baaab608b6d40a494
<img width="1920" height="1080" alt="Screenshot (7)" src="https://github.com/user-attachments/assets/8019f56a-a15e-4e94-aca3-7bf534ff7b78" />
