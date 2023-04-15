import {
  assert,
  describe,
  test,
  clearStore,
  beforeAll,
  afterAll
} from "matchstick-as/assembly/index"
import { Bytes, BigInt, Address } from "@graphprotocol/graph-ts"
import { GasTankFilled } from "../generated/schema"
import { GasTankFilled as GasTankFilledEvent } from "../generated/PromotionMain/PromotionMain"
import { handleGasTankFilled } from "../src/promotion-main"
import { createGasTankFilledEvent } from "./promotion-main-utils"

// Tests structure (matchstick-as >=0.5.0)
// https://thegraph.com/docs/en/developer/matchstick/#tests-structure-0-5-0

describe("Describe entity assertions", () => {
  beforeAll(() => {
    let _promotionId = Bytes.fromI32(1234567890)
    let ethGasLeft = BigInt.fromI32(234)
    let newGasTankFilledEvent = createGasTankFilledEvent(
      _promotionId,
      ethGasLeft
    )
    handleGasTankFilled(newGasTankFilledEvent)
  })

  afterAll(() => {
    clearStore()
  })

  // For more test scenarios, see:
  // https://thegraph.com/docs/en/developer/matchstick/#write-a-unit-test

  test("GasTankFilled created and stored", () => {
    assert.entityCount("GasTankFilled", 1)

    // 0xa16081f360e3847006db660bae1c6d1b2e17ec2a is the default address used in newMockEvent() function
    assert.fieldEquals(
      "GasTankFilled",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "_promotionId",
      "1234567890"
    )
    assert.fieldEquals(
      "GasTankFilled",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "ethGasLeft",
      "234"
    )

    // More assert options:
    // https://thegraph.com/docs/en/developer/matchstick/#asserts
  })
})
