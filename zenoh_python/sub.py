import zenoh, time

def listener(sample):
    print(f"Received {sample.kind} ('{sample.key_expr}': '{sample.payload.decode('utf-8')}')")

if __name__ == "__main__":
    session = zenoh.open()
    sub = session.declare_subscriber('key/expression', listener)
    time.sleep(60)
