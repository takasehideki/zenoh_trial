use zenoh::prelude::r#async::*;

use ctrlc_handler::CtrlCHandler;
use std::{thread, time};

#[async_std::main]
async fn main() {
    let session = zenoh::open(config::peer()).res().await.unwrap().into_arc();
    let publisher = session.declare_publisher("key/expression").res().await.unwrap();

    let handler = CtrlCHandler::new();
    while handler.should_continue() {
        publisher.put("value").res().await.unwrap();

        thread::sleep(time::Duration::from_millis(1000));
    }

    publisher.delete().res().await.unwrap();
}
