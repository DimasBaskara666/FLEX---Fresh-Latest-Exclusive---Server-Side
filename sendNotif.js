// npm install axios
const axios = require("axios");

const token =
  "ya29.c.c0ASRK0GbCX_aTPDHJ6jwzd75PaAqy7de2S0CjgwuytXtoW3YeSp8gdrk1JMD9VJ68JHVRUGOn5z3_6AJ-3QqC9gXMGg50KQ8nIxTvr4PbcRBBGe-Yede_Ty8GJYgP5Y8sJEkzgtPPyKRo9antge3FfFDnDHx9L7nrSMJmYJcBqbXcCr7Zn-ZbEsUvF2ys3_5nSycUNz127eo81uynsm5u86WLKg5IOZ2hOxtPDi87JL89BEvgozV_o1naFHvOGkm97GKZWA1063ZyXAClxjDfdvAeo8XEUVbMVYHxFQwjdGp8bcrirzaia0Ug-RuWr4biQEf8rJ4A84-JI7x0r19XALP8-K_xZkHt3-oZA5qJxAStP5las3JDt6lyRQE387DQi9or9-mdqju09FW13Fjalw9z__700Xbc2oxFMuQVg8txq46wux20F0ue40l8fMqiwdsbjeOVlfxrt-cfS2fi6StR2dsgzagzilq93yRf_-kmnekZ1Zq161sXz8jiW_b7tbqmtJ1cbbSohg451k3ZssgggUfJXtSpF7WcsW64atqZ-hc0ZRlbfoxc4014nI3eB3jFFs9hiVaas-Vf0IVe-64vkMWxfadVwMyayrUM9s0VRni_yiQsvJxQWg9a_l7w1SbrY35JwXaIsMsbr14B7x3wSIM3nMj6wFXJwdXFXQcUkz3UgYiob1FvXZkM0Uz1-dBhmgk0Yjt0Fg8gd90yOVk6O0vgag3QvWBJgy6OUw-b9qu7ob2tw66QmFOQVWnVsJZIfSkmwp0BSxUft_nchdZibl8d1ZI7bg1-Fncvq9e5ciQMdiyX3iZQ2oxt-M5pBg4z1MSaF0WgmcBS7oMpVZYopggzai3Og85md7nb_Xj1IbQXFt2swrOVRVVYJI-pgWFbuWk5QROFOfirntOSMq40Snj4tOY4Su8duB35jdFwbgUcSx2JxQzjhamdJmU3nQ0z-k_UJ1nMBtRU7_o5eq4e45kZUitmOxbXXaoj_WZeJY9h4uiw0FU"; // Replace with your generated token

const url =
  "https://fcm.googleapis.com/v1/projects/flexnews-dc855/messages:send";

const messagePayload = {
  message: {
    topic: "all_devices",
    notification: {
      title: "Don't miss out!",
      body: "IPHONE 17 DESIGN GOT LEAKED",
    },
    data: {
      type: "news", // Used for navigation
    },
    android: {
      priority: "high",
      notification: {
        channel_id: "high_importance_channel",
      },
    },
  },
};

const headers = {
  Authorization: `Bearer ${token}`,
  "Content-Type": "application/json",
};

axios
  .post(url, messagePayload, { headers })
  .then((response) => {
    console.log("Message sent successfully:", response.data);
  })
  .catch((error) => {
    console.error(
      "Error sending message:",
      error.response ? error.response.data : error.message
    );
  });
