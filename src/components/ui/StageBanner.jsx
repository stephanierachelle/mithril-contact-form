const m = require("mithril");

import StageTitle from "./StageTitle.jsx";

const StageBanner = {
    view: ({ attrs }) => (
    <div class="stage-banner">
    <StageTitle title={attrs.title} />
    </div>
    )
};

export default StageBanner;