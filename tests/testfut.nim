#              Asyncdispatch2 Test Suite
#                 (c) Copyright 2018
#         Status Research & Development GmbH
#
#              Licensed under either of
#  Apache License, version 2.0, (LICENSE-APACHEv2)
#              MIT license (LICENSE-MIT)

import unittest
import ../asyncdispatch2

proc testFuture1(): Future[int] {.async.} =
  await sleepAsync(100)

proc testFuture2(): Future[int] {.async.} =
  return 1

proc testFuture3(): Future[int] {.async.} =
  result = await testFuture2()

proc test1(): bool =
  var fut = testFuture1()
  poll()
  poll()
  result = fut.finished

proc test2(): bool =
  var fut = testFuture3()
  result = fut.finished

proc test3(): string =
  var testResult = ""
  var fut = testFuture1()
  fut.addCallback proc(udata: pointer) =
    testResult &= "1"
  fut.addCallback proc(udata: pointer) =
    testResult &= "2"
  fut.addCallback proc(udata: pointer) =
    testResult &= "3"
  fut.addCallback proc(udata: pointer) =
    testResult &= "4"
  fut.addCallback proc(udata: pointer) =
    testResult &= "5"
  discard waitFor(fut)
  poll()
  if fut.finished:
    result = testResult

proc test4(): string =
  var testResult = ""
  var fut = testFuture1()
  proc cb1(udata: pointer) =
    testResult &= "1"
  proc cb2(udata: pointer) =
    testResult &= "2"
  proc cb3(udata: pointer) =
    testResult &= "3"
  proc cb4(udata: pointer) =
    testResult &= "4"
  proc cb5(udata: pointer) =
    testResult &= "5"
  fut.addCallback cb1
  fut.addCallback cb2
  fut.addCallback cb3
  fut.addCallback cb4
  fut.addCallback cb5
  fut.removeCallback cb3
  discard waitFor(fut)
  poll()
  if fut.finished:
    result = testResult

when isMainModule:
  suite "Future[T] behavior test suite":
    test "Async undefined behavior (#7758) test":
      check test1() == true
    test "Immediately completed asynchronous procedure test":
      check test2() == true
    test "Future[T] callbacks are invoked in reverse order (#7197) test":
      check test3() == "12345"
    test "Future[T] callbacks not changing order after removeCallback()":
      check test4() == "1245"
