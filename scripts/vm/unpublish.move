script {
use 0x3::Vm;
fun publish(account: signer) {
    Vm::unpublish(&account);
}
}