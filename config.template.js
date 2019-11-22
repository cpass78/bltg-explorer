const { SocialType } = require('./features/social/data');

/**
 * Global configuration object.
 *
 * Running:
 * yarn run start:api
 * yarn run start:web (Access project via http://localhost:8081/) (port comes from webpack.config.js)
 *
 * For nginx server installation and production read /script/install.sh `installNginx ()`. Note that we use Certbot to grant SSL certificate.
 *
 */
const config = {
  api: {
    host: 'http://localhost', // ex: 'https://explorer.block-logic.com' for nginx (SSL), 'http://IP_ADDRESS'
    port: '3000', // ex: Port 3000 on prod and localhost
    portWorker: '3000', // ex: Port 443 for production(ngingx) if you have SSL (we use certbot), 3000 on localhost or ip
    prefix: '/api',
    timeout: '5s'
  },
  coinDetails: {
    name: 'Block-Logic',
    shortName: 'BLTG',
    longName: 'BLTG Cryptocurrency',
    websiteUrl: 'https://block-logic.com/',
    telegram: 'https://t.me/bltgx',
    github: 'https://github.com/Block-Logic-Technology-Group',
    discord: 'https://discord.gg/cWUSgUE',
    twitter: 'https://twitter.com/BlockLogicTech',
    medium: 'https://medium.com/@BlockLogic',
    forum: 'https://forum.block-logic.com/',

    displayDecimals: 2,
    coinNumberFormat: '0,0.0000',
    coinTooltipNumberFormat: '0,0.0000000000', // Hovering over a number will show a larger percision tooltip
    masternodeCollateral: 12000, // MN ROI% gets based on this number. If your coin has multi-tiered masternodes then set this to lowest tier (ROI% will simply be higher for bigger tiers)
  },
  offChainSignOn: {
    enabled: true,
    signMessagePrefix: 'BLTGSIGN-' // Unique prefix in "Message To Sign" for Off-Chain Sign On
  },

  // Add any important block counting down in this array
  blockCountdowns: [
    // {
    //   block: 602880, // What block are we counting down to?
    //   beforeTitle: 'Next Superblock', // What do we show before the block number is hit?
    //   afterTitle: 'Superblock Active For' // What do we show after the block number is hit?
    // }
  ],

  /**
   * API & Social configurations
   */

  /**
   * Social integrations are all aggregated into a single table & common format. For example, you can have mulitple reddit integrations with different flairs.
   */
  social: [
    {
      name: 'developmentUpdates', // Unique name of the social widget
      type: SocialType.Reddit, // What type of social widget is it?
      group: 'community', // Multiple social widget feeds can be combined into a single cross-app group feed
      options: {
        subreddit: 'MyAwesomeCoin', // Block-Logic as an example
        query: 'flair:"Community"' // Show only posts with Community flair (the little tag next to post) (You can empty this to show all posts or specify your own filter based on https://www.reddit.com/wiki/search)
      }
    }
  ],

  freegeoip: {
    api: 'https://extreme-ip-lookup.com/json/' //@todo need to find new geoip service as the limits are too small now (hitting limits)
  },
  coinMarketCap: {
    api: 'http://api.coinmarketcap.com/v1/ticker/',
    ticker: 'block-logic'
  },
  coinGecko: {
    api: 'https://coingecko.com/api/documentations/v3/',
    ticker: 'bitcoin-lightning'
  },

  /**
   * Explorer Customization
   */
  desktopMenuExpanded: true,        // If set to true the website will have opened navigation bar on load

  /**
   * Community & Address Related
   */
  community: {
    // If you comment out all of these addresses the 'Community Addresses' section will not show up on the homepage. You can add as many addresses to highlight as you wish.
    highlightedAddresses: [
      //{ label: 'Community Donations', address: 'XXXXXXXXXXXXXXXXXXXXXXXXXXX' }, // Uncomment and replace with your coin address to highlight an address
      //{ label: 'Community Funding', address: 'XXXXXXXXXXXXXXXXXXXXXXXXXXX' }, // Uncomment and replace with your coin address to highlight any other address
    ],

    // It's hard to identify governance vs mn rewards in Dash. Add any governance addresses here, any masternode rewards into these addresses will count as governance reward instead of MN rewards
    governanceAddresses: [
      /**
       * If you have governance voting in your coin you can add the voting addresses to below.
       * This is only required because governance rewards are simply replacing MN block reward (so they are identical on the blockchain)
       */

      /*
      // 72000 BLTG 159ff849ae833c3abd05a7b36c5ecc7c4a808a8f1ef292dad0b02875009e009e
      "bZ1HJB1kEb1KFcVA42viGJPM7896rsRp9x",
      */
    ]
  },
  // Each address can contain it's own set of widgets and configs for those widgets
  addressWidgets: {
    'XXXXXXXXXXXXXXXXXXXXXXXXXXX': {
      // WIDGET: Adds a list of masternodes when viewing address. We use this to show community-ran masternodes
      masternodesAddressWidget: {
        title: 'Community Masternodes',
        description: 'Profits from these masternodes fund & fuel community talent',
        isPaginationEnabled: false, // If you have more than 10 you should enable this
        addresses: [
          'XXXXXXXXXXXXXXXXXXXXXXXXXXX',
          'XXXXXXXXXXXXXXXXXXXXXXXXXXX',
          'XXXXXXXXXXXXXXXXXXXXXXXXXXX',
        ]
      }
    },
    'FEE': {
      // Adds a new label metadata address
      carverAddressLabelWidget: {
        label: 'Transaction Fee ⌚',
        title: 'A small portion of a transaction will be sent to this address. Referred to as "Transaction Fee".'
      }
    },
    'COINBASE': {
      // Adds a new label metadata address
      carverAddressLabelWidget: {
        label: 'Coinbase (Premine & POW) 💎',
        title: 'This address was active during Proof Of Work (POW) phase to distribute rewards to miners & masternode owners.'
      }
    },
    'MN': {
      // Adds a new label metadata address
      carverAddressLabelWidget: {
        label: 'Masternode Rewards 💎',
        title: 'Each block contains a small portion that is awarded to masternode operators that lock 12000 BLTG. Masternodes contribute to the network by handling certain coin operations within the network.'
      }
    },
    'POW': {
      // Adds a new label metadata address
      carverAddressLabelWidget: {
        label: 'Proof Of Work Rewards 💎',
        title: 'Block-Logic started as a Proof Of Work & Masternode coin. Blocks would be mined by powerful computers and be rewarded for keeping up the network.'
      }
    },
    'POS': {
      // Adds a new label metadata address
      carverAddressLabelWidget: {
        label: 'Proof Of Stake Rewards 💎',
        title: 'Inputs that are over 1 BLTG can participate in network upkeep. Each block (~60 seconds) one of these inputs is rewarded for keeping up the network.'
      }
    },
  },

  /**
   * Adjustable POS Profitability Score - How profitable is your staking, tailored for your blockchain
   */
  profitabilityScore: {
    scoreStyles: [
      // Best case
      {
        color: '#72f87b',
        title: 'Excellent!!!'
      },
      {
        color: '#84f771',
        title: 'Excellent!'
      },
      {
        color: '#a0f771',
        title: 'Excellent'
      },
      {
        color: '#bcf671',
        title: 'Very Good'
      },
      {
        color: '#d8f671',
        title: 'Above Average'
      },
      {
        color: '#f3f671',
        title: 'Average'
      },
      {
        color: '#f5dc71',
        title: 'Below Average'
      },
      {
        color: '#f5c071',
        title: 'Not Optimal'
      },
      {
        color: '#f4a471',
        title: 'Not Optimal!'
      },
      // Worst case (default)
      {
        color: '#f48871',
        title: 'Not Optimal!!!'
      }
    ]
  },

  /**
   * Cron & Syncing
   */
  blockConfirmations: 10,           // We will re-check block "merkleroot" this many blocks back. If they differ we will then start unwinding carver movements one block at a time until correct block is found. (This is like min confirmations)
  verboseCron: true,                // If set to true there are extra logging details in cron scripts
  verboseCronTx: false,             // If set to true there are extra tx logging details in cron scripts (Not recommended)
  blockSyncAddressCacheLimit: 5000 // How many addresses to keep in memory during block syncing (When this number is reached the entire cache is flushed and filled again from beginning)
};

module.exports = config;
