use zenoh::prelude::r#async::*;

#[async_std::main]
async fn main() {
    let session = zenoh::open(config::default()).res().await.unwrap();
    session.put("key/expression", "value").res().await.unwrap();
    session.close().res().await.unwrap();
}
