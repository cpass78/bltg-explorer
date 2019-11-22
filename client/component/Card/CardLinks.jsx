
import React from 'react';

import Card from './Card';
import config from '../../../config';

const CardLinks = () => (
  <Card title="Links">
    <a href={config.coinDetails.websiteUrl} target="_blank" rel="nofollow noopener">Website</a><br />
    {/*<a href="https://bitcointalk.org/index.php?topic=2499481.0" target="_blank" rel="nofollow noopener">Bitcointalk</a><br />*/}
    <a href={config.coinDetails.github} target="_blank" rel="nofollow noopener">Github</a><br />
    {/*<a href="https://www.reddit.com/r/BulwarkCoin/" target="_blank" rel="nofollow noopener">Reddit</a><br />*/}
    <a href={config.coinDetails.discord} target="_blank" rel="nofollow noopener">Discord</a><br />
    <a href={config.coinDetails.telegram} target="_blank" rel="nofollow noopener">Telegram</a><br />
    <a href={config.coinDetails.twitter} target="_blank" rel="nofollow noopener">Twitter</a><br />
    <a href={config.coinDetails.medium} target="_blank" rel="nofollow noopener">Medium</a><br />
    <a href={config.coinDetails.forum} target="_blank" rel="nofollow noopener">Community Forum</a>
  </Card>
);

export default CardLinks;
