import { newMockEvent } from "matchstick-as"
import { ethereum, Bytes, BigInt, Address } from "@graphprotocol/graph-ts"
import {
  GasTankFilled,
  GasTankRefunded,
  PromotionClaimed,
  PromotionCreated
} from "../generated/ZaisanMain/ZaisanMain"

export function createGasTankFilledEvent(
  _promotionId: Bytes,
  ethGasLeft: BigInt
): GasTankFilled {
  let gasTankFilledEvent = changetype<GasTankFilled>(newMockEvent())

  gasTankFilledEvent.parameters = new Array()

  gasTankFilledEvent.parameters.push(
    new ethereum.EventParam(
      "_promotionId",
      ethereum.Value.fromFixedBytes(_promotionId)
    )
  )
  gasTankFilledEvent.parameters.push(
    new ethereum.EventParam(
      "ethGasLeft",
      ethereum.Value.fromUnsignedBigInt(ethGasLeft)
    )
  )

  return gasTankFilledEvent
}

export function createGasTankRefundedEvent(
  promotionId: Bytes,
  amount: BigInt
): GasTankRefunded {
  let gasTankRefundedEvent = changetype<GasTankRefunded>(newMockEvent())

  gasTankRefundedEvent.parameters = new Array()

  gasTankRefundedEvent.parameters.push(
    new ethereum.EventParam(
      "promotionId",
      ethereum.Value.fromFixedBytes(promotionId)
    )
  )
  gasTankRefundedEvent.parameters.push(
    new ethereum.EventParam("amount", ethereum.Value.fromUnsignedBigInt(amount))
  )

  return gasTankRefundedEvent
}

export function createPromotionClaimedEvent(
  promotionId: Bytes,
  claimer: Address,
  claimsCount: BigInt,
  ethGasLeft: BigInt,
  claimedAt: BigInt
): PromotionClaimed {
  let promotionClaimedEvent = changetype<PromotionClaimed>(newMockEvent())

  promotionClaimedEvent.parameters = new Array()

  promotionClaimedEvent.parameters.push(
    new ethereum.EventParam(
      "promotionId",
      ethereum.Value.fromFixedBytes(promotionId)
    )
  )
  promotionClaimedEvent.parameters.push(
    new ethereum.EventParam("claimer", ethereum.Value.fromAddress(claimer))
  )
  promotionClaimedEvent.parameters.push(
    new ethereum.EventParam(
      "claimsCount",
      ethereum.Value.fromUnsignedBigInt(claimsCount)
    )
  )
  promotionClaimedEvent.parameters.push(
    new ethereum.EventParam(
      "ethGasLeft",
      ethereum.Value.fromUnsignedBigInt(ethGasLeft)
    )
  )
  promotionClaimedEvent.parameters.push(
    new ethereum.EventParam(
      "claimedAt",
      ethereum.Value.fromUnsignedBigInt(claimedAt)
    )
  )

  return promotionClaimedEvent
}

export function createPromotionCreatedEvent(
  promotionId: Bytes,
  groupId: Bytes,
  destinationDomain: BigInt,
  claimsPerPerson: BigInt,
  postId: string,
  tokenAddress: Address,
  ethGasLeft: BigInt,
  badgeURI: string,
  creator: Address
): PromotionCreated {
  let promotionCreatedEvent = changetype<PromotionCreated>(newMockEvent())

  promotionCreatedEvent.parameters = new Array()

  promotionCreatedEvent.parameters.push(
    new ethereum.EventParam(
      "promotionId",
      ethereum.Value.fromFixedBytes(promotionId)
    )
  )
  promotionCreatedEvent.parameters.push(
    new ethereum.EventParam("groupId", ethereum.Value.fromFixedBytes(groupId))
  )
  promotionCreatedEvent.parameters.push(
    new ethereum.EventParam(
      "destinationDomain",
      ethereum.Value.fromUnsignedBigInt(destinationDomain)
    )
  )
  promotionCreatedEvent.parameters.push(
    new ethereum.EventParam(
      "claimsPerPerson",
      ethereum.Value.fromUnsignedBigInt(claimsPerPerson)
    )
  )
  promotionCreatedEvent.parameters.push(
    new ethereum.EventParam("postId", ethereum.Value.fromString(postId))
  )
  promotionCreatedEvent.parameters.push(
    new ethereum.EventParam(
      "tokenAddress",
      ethereum.Value.fromAddress(tokenAddress)
    )
  )
  promotionCreatedEvent.parameters.push(
    new ethereum.EventParam(
      "ethGasLeft",
      ethereum.Value.fromUnsignedBigInt(ethGasLeft)
    )
  )
  promotionCreatedEvent.parameters.push(
    new ethereum.EventParam("badgeURI", ethereum.Value.fromString(badgeURI))
  )
  promotionCreatedEvent.parameters.push(
    new ethereum.EventParam("creator", ethereum.Value.fromAddress(creator))
  )

  return promotionCreatedEvent
}
