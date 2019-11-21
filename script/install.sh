#!/bin/bash

installNodeAndYarn () {
    echo "Installing nodejs and yarn..."
    sudo curl -sL https://deb.nodesource.com/setup_8.x | sudo bash -
    sudo apt-get install -y nodejs npm
    sudo curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
    sudo echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
    sudo apt-get update -y
    sudo apt-get install -y yarn
    sudo npm install -g pm2
    sudo ln -s /usr/bin/nodejs /usr/bin/node
    sudo chown -R explorer:explorer /home/explorer/.config
    clear
}

installNginx () {
    echo "Installing nginx..."
    sudo apt-get install -y nginx
    sudo rm -f /etc/nginx/sites-available/default
    sudo cat > /etc/nginx/sites-available/default << EOL
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    index index.html index.htm index.nginx-debian.html;
    #server_name explorer.block-logic.com;
    server_name _;

    gzip on;
    gzip_static on;
    gzip_disable "msie6";

    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_buffers 16 8k;
    gzip_http_version 1.1;
    gzip_min_length 256;
    gzip_types text/plain text/css application/json application/javascript application/x-javascript text/xml application/xml application/xml+rss text/javascript application/vnd.ms-fontobject application/x-font-ttf font/opentype image/svg+xml image/x-icon;

    location / {
        proxy_pass http://127.0.0.1:3000;
            proxy_http_version 1.1;
            proxy_set_header Upgrade \$http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host \$host;
            proxy_cache_bypass \$http_upgrade;
    }

    #listen [::]:443 ssl ipv6only=on; # managed by Certbot
    #listen 443 ssl; # managed by Certbot
    #ssl_certificate /etc/letsencrypt/live/explorer.block-logic.com/fullchain.pem; # managed by Certbot
    #ssl_certificate_key /etc/letsencrypt/live/explorer.block-logic.com/privkey.pem; # managed by Certbot
    #include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    #ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot
}

#server {
#    if ($host = explorer.block-logic.com) {
#        return 301 https://\$host\$request_uri;
#    } # managed by Certbot
#
#	listen 80 default_server;
#	listen [::]:80 default_server;
#
#	server_name explorer.block-logic.com;
#   return 404; # managed by Certbot
#}
EOL
    sudo systemctl start nginx
    sudo systemctl enable nginx
    clear
}

installMongo () {
    echo "Installing mongodb..."
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5
    sudo echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.6 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.6.list
    sudo apt-get update -y
    sudo apt-get install -y --allow-unauthenticated mongodb-org
    sudo chown -R mongodb:mongodb /data/db
    sudo systemctl start mongod
    sudo systemctl enable mongod
    mongo blockex --eval "db.createUser( { user: \"$rpcuser\", pwd: \"$rpcpassword\", roles: [ \"readWrite\" ] } )"
    clear
}

installBltg () {
    echo "Installing Bltg..."
    mkdir -p /tmp/bltg
    cd /tmp/bltg
    curl -Lo bltg.tar.gz $bltglink
    tar -xzf bltg.tar.gz
    sudo mv * /usr/local/bin
    cd
    rm -rf /tmp/bulwark
    mkdir -p /home/explorer/.bltg
    cat > sudo /home/explorer/.bltg/bltg.conf << EOL
rpcport=52544
rpcuser=$rpcuser
rpcpassword=$rpcpassword
daemon=1
txindex=1
EOL
    sudo cat > sudo /etc/systemd/system/bltgd.service << EOL
[Unit]
Description=bltgd
After=network.target
[Service]
Type=forking
User=explorer
WorkingDirectory=/home/explorer
ExecStart=/usr/local/bin/bltgd -datadir=/home/explorer/.bltg
ExecStop=/usr/local/bin/bltg-cli -datadir=/home/explorer/.bltg stop
Restart=on-abort
[Install]
WantedBy=multi-user.target
EOL
    sudo systemctl start bltgd
    sudo systemctl enable bltgd
    echo "Sleeping for 1 hour while node syncs blockchain..."
    sleep 1h
    clear
}

installBlockEx () {
    echo "Installing BlockEx..."
    git clone https://github.com/Block-Logic-Technology-Group/bltg.git /home/explorer/blockex
    cd /home/explorer/blockex
    yarn install
    cat > /home/explorer/blockex/config.server.js << EOL
/**
 * Keep all your API & secrets here. DO NOT IMPORT THIS FILE IN /client folder
 */
const secretsConfig = {
  db: {
    host: '127.0.0.1',
    port: '27017',
    name: 'blockex',
    user: 'blockexuser',
    pass: 'Explorer!1'
  },
  rpc: {
    host: '127.0.0.1',
    port: '52541',
    user: 'bltgrpc',
    pass: 'someverysafepassword',
    timeout: 8000, // 8 seconds
  },
}

module.exports = { secretsConfig }; // This is returned as an object on purpose so you have to be explicit at stating that you are accessing a secrets config
EOL
    cat > /home/explorer/blockex/config.js << EOL

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
    displayDecimals: 2,
    longName: 'Block-Logic Cryptocurrency',
    coinNumberFormat: '0,0.0000',
    coinTooltipNumberFormat: '0,0.0000000000', // Hovering over a number will show a larger percision tooltip
    websiteUrl: 'https://block-logic.com/',
    masternodeCollateral: 12000 // MN ROI% gets based on this number. If your coin has multi-tiered masternodes then set this to lowest tier (ROI% will simply be higher for bigger tiers)
  },
  offChainSignOn: {
    enabled: true,
    signMessagePrefix: 'BLTGSIGN-' // Unique prefix in "Message To Sign" for Off-Chain Sign On
  },

  // Add any important block counting down in this array
  blockCountdowns: [
//    {
//      block: 602880, // What block are we counting down to?
//      beforeTitle: 'Next Superblock', // What do we show before the block number is hit?
//      afterTitle: 'Superblock Active For' // What do we show after the block number is hit?
//    }
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
        subreddit: 'MyAwesomeCoin', // Block-logic as an example
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
       * This is only requried because governance rewards are simply replacing MN block reward (so they are identical on the blockchain)
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
        label: 'Transaction Fee âŒš',
        title: 'A small portion of a transaction will be sent to this address. Referred to as "Transaction Fee".'
      }
    },
    'COINBASE': {
      // Adds a new label metadata address
      carverAddressLabelWidget: {
        label: 'Coinbase (Premine & POW) ðŸ’Ž',
        title: 'This address was active during Proof Of Work (POW) phase to distribute rewards to miners & masternode owners.'
      }
    },
    'MN': {
      // Adds a new label metadata address
      carverAddressLabelWidget: {
        label: 'Masternode Rewards ðŸ’Ž',
        title: 'Each block contains a small portion that is awarded to masternode operators that lock 5000 BWK. Masternodes contribute to the network by handling certain coin operations within the network.'
      }
    },
    'POW': {
      // Adds a new label metadata address
      carverAddressLabelWidget: {
        label: 'Proof Of Work Rewards ðŸ’Ž',
        title: 'Block-Logic started as a Proof Of Work & Masternode coin. Blocks would be mined by powerful computers and be rewarded for keeping up the network.'
      }
    },
    'POS': {
      // Adds a new label metadata address
      carverAddressLabelWidget: {
        label: 'Proof Of Stake Rewards ðŸ’Ž',
        title: 'Inputs that are over 100 BWK can participate in network upkeep. Each block (~90 seconds) one of these inputs is rewarded for keeping up the network.'
      }
    },
  },

  ///////////////////////////////
  // Adjustable POS Profitability Score - How profitable is your staking, tailored for your blockchain
  ///////////////////////////////
  profitabilityScore: {
    scoreStyles: [
      // Best case
      {
        color: '#72f87b',
        title: 'Rank 1/10 - Excellent!!!'
      },
      {
        color: '#84f771',
        title: 'Rank 2/10 - Excellent!'
      },
      {
        color: '#a0f771',
        title: 'Rank 3/10 - Excellent'
      },
      {
        color: '#bcf671',
        title: 'Rank 4/10 - Very Good'
      },
      {
        color: '#d8f671',
        title: 'Rank 5/10 - Above Average'
      },
      {
        color: '#f3f671',
        title: 'Rank 6/10 - Average'
      },
      {
        color: '#f5dc71',
        title: 'Rank 7/10 - Below Average'
      },
      {
        color: '#f5c071',
        title: 'Rank 8/10 - Not Optimal'
      },
      {
        color: '#f4a471',
        title: 'Rank 9/10 - Not Optimal!'
      },
      // Worst case (default)
      {
        color: '#f48871',
        title: 'Rank 10/10 - Not Optimal!!!'
      }
    ]
  },

  ///////////////////////////////
  /// Cron & Syncing
  ///////////////////////////////
  blockConfirmations: 10,           // We will re-check block "merkleroot" this many blocks back. If they differ we will then start unwinding carver movements one block at a time until correct block is found. (This is like min confirmations)
  verboseCron: true,                // If set to true there are extra logging details in cron scripts
  verboseCronTx: false,             // If set to true there are extra tx logging details in cron scripts (Not recommended)
  blockSyncAddressCacheLimit: 50000 // How many addresses to keep in memory during block syncing (When this number is reached the entire cache is flushed and filled again from beginning)
};

module.exports = config;
EOL
    nodejs ./cron/block.js
    nodejs ./cron/coin.js
    nodejs ./cron/masternode.js
    nodejs ./cron/peer.js
    nodejs ./cron/rich.js
    clear
    cat > mycron << EOL
*/1 * * * * cd /home/explorer/blockex && ./script/cron_block.sh >> ./tmp/block.log 2>&1
*/1 * * * * cd /home/explorer/blockex && /usr/bin/nodejs ./cron/masternode.js >> ./tmp/masternode.log 2>&1
*/1 * * * * cd /home/explorer/blockex && /usr/bin/nodejs ./cron/peer.js >> ./tmp/peer.log 2>&1
*/1 * * * * cd /home/explorer/blockex && /usr/bin/nodejs ./cron/rich.js >> ./tmp/rich.log 2>&1
*/5 * * * * cd /home/explorer/blockex && /usr/bin/nodejs ./cron/coin.js >> ./tmp/coin.log 2>&1
0 0 * * * cd /home/explorer/blockex && /usr/bin/nodejs ./cron/timeIntervals.js >> ./tmp/timeIntervals.log 2>&1
EOL
    crontab mycron
    rm -f mycron
    pm2 start ./server/index.js
    sudo pm2 startup ubuntu
}

# Setup
echo "Updating system..."
sudo apt-get update -y
sudo apt-get install -y apt-transport-https build-essential cron curl gcc git g++ make sudo vim wget
clear

# Variables
echo "Setting up variables..."
bltglink=`curl -s https://api.github.com/repos/Block-Logic-Technology-Group/bltg/releases/latest | grep browser_download_url | grep x86_64-linux | cut -d '"' -f 4`
rpcuser=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13 ; echo '')
rpcpassword=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 32 ; echo '')
echo "Repo: $bltglink"
echo "PWD: $PWD"
echo "User: $rpcuser"
echo "Pass: $rpcpassword"
sleep 5s
clear

# Check for blockex folder, if found then update, else install.
if [ ! -d "/home/explorer/blockex" ]
then
    installNginx
    installMongo
    #installBltg
    installNodeAndYarn
    installBlockEx
    echo "Finished installation!"
else
    cd /home/explorer/blockex
    git pull
    pm2 restart index
    echo "BlockEx updated!"
fi
