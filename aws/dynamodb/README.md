# AWS DynamoDB (Always Free) Documentation

**Current Phase**: Documentation

This document describes AWS DynamoDB and how to use it within the always-free tier limits.

## 🎯 Always Free Limits

AWS DynamoDB is part of the AWS **always-free tier** (not limited to 12 months):

- **25 GB** of indexed data storage (perpetually free)
- **25 provisioned Write Capacity Units (WCU)** (perpetually free)
- **25 provisioned Read Capacity Units (RCU)** (perpetually free)
- **25 GB** of additional storage for backups and streams
- **2.5 million stream read requests** per month (DynamoDB Streams)
- **1 GB** of data transfer out (first 1GB free, then part of AWS 100GB aggregate)
- **No time limit**: These limits never expire

### Understanding Capacity Units

**Read Capacity Units (RCU)**:
- 1 RCU = 1 strongly consistent read per second for items up to 4KB
- 1 RCU = 2 eventually consistent reads per second for items up to 4KB
- 25 RCU free = 25 consistent reads/sec OR 50 eventually consistent reads/sec

**Write Capacity Units (WCU)**:
- 1 WCU = 1 write per second for items up to 1KB
- 25 WCU free = 25 writes per second

### Practical Examples

**Example 1: Simple Key-Value Store**
- Table size: 5GB
- Reads: 10 RCU (10 reads/sec)
- Writes: 5 WCU (5 writes/sec)
- **Result**: Well within free tier ✅

**Example 2: User Session Store**
- Table size: 15GB
- Reads: 20 RCU (40 eventually consistent reads/sec)
- Writes: 10 WCU (10 writes/sec)
- **Result**: Within free tier ✅

**Example 3: Application Database**
- Table size: 24GB
- Reads: 25 RCU (maximum free)
- Writes: 25 WCU (maximum free)
- **Result**: At free tier limit ⚠️

## ⚠️ What Causes Charges

You will incur charges if:
- ❌ Exceed 25GB storage
- ❌ Exceed 25 provisioned RCU
- ❌ Exceed 25 provisioned WCU
- ❌ Use On-Demand capacity mode (charged per request, no free tier)
- ❌ Use Global Tables (replication charges)
- ❌ Use DynamoDB Accelerator (DAX) - not free
- ❌ Use Point-in-Time Recovery (PITR) - not free
- ❌ Use DynamoDB Transactions (2× cost)
- ❌ Exceed data transfer limits
- ❌ Use reserved capacity (upfront payment)

## 🏗️ Use Cases Within Free Tier

### Excellent Use Cases
- ✅ **User sessions**: Fast session storage for web apps
- ✅ **Configuration store**: Application settings and feature flags
- ✅ **User profiles**: User data, preferences, settings
- ✅ **Metadata storage**: File metadata, index data
- ✅ **IoT device state**: Device status and telemetry
- ✅ **Gaming leaderboards**: High scores and rankings
- ✅ **Cache layer**: Fast data retrieval
- ✅ **Event logging**: Application events (within storage limits)
- ✅ **Shopping carts**: E-commerce cart data
- ✅ **API rate limiting**: Track API usage per user

### Consider Alternatives For
- ⚠️ **Large datasets**: >25GB (consider pagination, archiving)
- ⚠️ **Complex queries**: DynamoDB is NoSQL, limited query capabilities
- ⚠️ **High traffic**: >25 RCU/WCU sustained (consider caching)
- ⚠️ **Analytics workloads**: Better suited for S3 + Athena
- ⚠️ **Relational data**: Consider RDS (not free tier) or normalize in DynamoDB

---

**Remember**: Always deploy [billing-alerts](../billing-alerts/) first! 🛡️
