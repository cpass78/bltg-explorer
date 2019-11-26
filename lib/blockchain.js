
const params = {
  LAST_POW_BLOCK: 300, // 345600
  RAMP_TO_BLOCK: 11,
  LAST_SEESAW_BLOCK: 0
};

const avgBlockTime = 60; // 1 minutes (60 seconds)

const blocksPerDay = (24 * 60 * 60) / avgBlockTime; // 1440

const blocksPerWeek = blocksPerDay * 7; // 10080

const blocksPerMonth = (blocksPerDay * 365.25) / 12; // 43830

const blocksPerYear = blocksPerDay * 365.25; // 525960

const mncoins = 12000.0;

const getMNBlocksPerDay = (mns) => {
  return blocksPerDay / mns;
};

const getMNBlocksPerWeek = (mns) => {
  return getMNBlocksPerDay(mns) * (365.25 / 52);
};

const getMNBlocksPerMonth = (mns) => {
  return getMNBlocksPerDay(mns) * (365.25 / 12);
};

const getMNBlocksPerYear = (mns) => {
  return getMNBlocksPerDay(mns) * 365.25;
};

const getMNSubsidy = (nHeight = 0) => {
  const blockValue = getSubsidy(nHeight);
  let ret = 0.0;

  if (nHeight > 10) {
    ret = blockValue * 0.8; // mn's always get 80%
  }
  return ret;
};

const getSubsidy = (nHeight = 0) => {
  let nSubsidy = 0.0;

  if (nHeight === 0) {
    nSubsidy = 3000000.00;
  } else if (nHeight < params.RAMP_TO_BLOCK) {
    nSubsidy = 3000000;
  } else if (nHeight < 20201 && nHeight >= 11) { // ~1 week for grace period
    nSubsidy = 1;
  } else if (nHeight <= 279400 && nHeight >= 20201) { // ~6 month period
    nSubsidy = 10;
  } else if (nHeight <= 538600 && nHeight >= 279401) { // ~6 month period
    nSubsidy = 9;
  } else if (nHeight <= 797800 && nHeight >= 538601) { // ~6 month period
    nSubsidy = 8;
  } else if (nHeight <= 1057000 && nHeight >= 797801) { // ~6 month period
    nSubsidy = 7;
  } else if (nHeight <= 1316200 && nHeight >= 1057001) { // ~6 month period
    nSubsidy = 6;
  } else {
    nSubsidy = 5;
  }
  return nSubsidy;
};

const getROI = (subsidy, mns) => {
  return ((getMNBlocksPerYear(mns) * subsidy) / mncoins) * 100.0;
};

const isAddress = (s) => {
  return typeof (s) === 'string' && s.length === 34;
};

const isBlock = (s) => {
  return !isNaN(s) || (typeof (s) === 'string');
};

const isPoS = (b) => {
  return !!b && b.height > params.LAST_POW_BLOCK; // > 300
};

const isTX = (s) => {
  return typeof (s) === 'string' && s.length === 64;
};

/**
 * How we identify if a raw transaction is Proof Of Stake & Masternode reward
 * @param {String} rpctx The transaction hash string.
 */
const isRewardRawTransaction = (rpctx) => {
  return rpctx.vin.length == 1 &&
    rpctx.vout.length == 3 && // @todo it's possible for reward to have >3 outputs. Ex: governance
    // First vout is always in this format
    rpctx.vout[0].value == 0.0 &&
    rpctx.vout[0].n == 0 &&
    rpctx.vout[0].scriptPubKey &&
    rpctx.vout[0].scriptPubKey.type == "nonstandard";

}

module.exports = {
  avgBlockTime,
  blocksPerDay,
  blocksPerMonth,
  blocksPerWeek,
  blocksPerYear,
  mncoins,
  params,
  getMNBlocksPerDay,
  getMNBlocksPerMonth,
  getMNBlocksPerWeek,
  getMNBlocksPerYear,
  getMNSubsidy,
  getSubsidy,
  getROI,
  isAddress,
  isBlock,
  isPoS,
  isTX,
  isRewardRawTransaction
};
