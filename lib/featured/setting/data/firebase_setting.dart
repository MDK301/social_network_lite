// async function deleteUser(email, password) {
//   try {
//     const userCredential = await signInWithEmailAndPassword(auth, email, password);
//     const user = userCredential.user;
//
//     //xóa tài khoản
//     await user.delete();
//     console.log("Tài khoản đã được xóa thành công!");
//   } catch (error) {
//     console.error("Lỗi khi xóa tài khoản:", error.message);
//   }
// }