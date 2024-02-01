use zenoh::prelude::r#async::*;

use ctrlc_handler::CtrlCHandler;
use std::{thread, time};

#[async_std::main]
async fn main() {
    let handler = CtrlCHandler::new();

    let session = zenoh::open(config::default()).res().await.unwrap();
    while handler.should_continue() {
        session.put("key/expression", "value").res().await.unwrap();

        thread::sleep(time::Duration::from_millis(1000));
    }
    session.close().res().await.unwrap();
}
