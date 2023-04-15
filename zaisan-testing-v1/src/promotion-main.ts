import { BigInt } from "@graphprotocol/graph-ts";
import {
  GasTankFilled as GasTankFilledEvent,
  GasTankRefunded as GasTankRefundedEvent,
  NewChainAdded as NewChainAddedEvent,
  PromotionClaimed as PromotionClaimedEvent,
  PromotionCreated as PromotionCreatedEvent,
} from "../generated/PromotionMain/PromotionMain";
import { Promotion, Claim } from "../generated/schema";

export function handleGasTankFilled(event: GasTankFilledEvent): void {
  let promotion = Promotion.load(event.params._promotionId.toHexString());
  if (!promotion) {
    promotion = new Promotion(event.params._promotionId.toHexString());
  }
  promotion.ethGas = event.params.ethGasLeft;
  promotion.save();
}

export function handleGasTankRefunded(event: GasTankRefundedEvent): void {
  let promotion = Promotion.load(event.params.promotionId.toHexString());
  if (!promotion) {
    promotion = new Promotion(event.params.promotionId.toHexString());
  }
  promotion.ethGas = event.params.amount;
  promotion.save();
}
export function handlePromotionClaimed(event: PromotionClaimedEvent): void {
  let claim = Claim.load(
    event.params.promotionId.toHexString() + event.params.claimer.toHexString()
  );
  let promotion = Promotion.load(event.params.promotionId.toHexString());

  if (!claim) {
    claim = new Claim(
      event.params.promotionId.toHexString() +
        event.params.claimer.toHexString()
    );
  }
  claim.currentClaims = event.params.claimsCount;
  claim.claimedAt = event.params.claimedAt;
  claim.claimer = event.params.claimer;
  if (!promotion) {
    promotion = new Promotion(event.params.promotionId.toHexString());
  }
  promotion.ethGas = event.params.ethGasLeft;
  promotion.save();
  claim.save();
}
export function handlePromotionCreated(event: PromotionCreatedEvent): void {
  let promotion = Promotion.load(event.params.promotionId.toHexString());
  if (!promotion) {
    promotion = new Promotion(event.params.promotionId.toHexString());
  }
  promotion.groupId = event.params.groupId;
  promotion.destinationDomain = event.params.destinationDomain;
  promotion.claimsPerPerson = event.params.claimsPerPerson;
  promotion.postId = event.params.postId;
  promotion.badgeURI = event.params.badgeURI;
  promotion.ethGas = event.params.ethGasLeft;
  promotion.createdAt = event.block.timestamp;
  promotion.tokenAddress = event.params.tokenAddress;
  promotion.creator = event.params.creator;
  promotion.save();
}
