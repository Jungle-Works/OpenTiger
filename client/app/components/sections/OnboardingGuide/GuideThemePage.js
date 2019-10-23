import { PropTypes } from 'react';
import r, { div, h2, p, img, a,span, i } from 'r-dom';
import css from './OnboardingGuide.css';
import { t } from '../../../utils/i18n';

import GuideBackToTodoLink from './GuideBackToTodoLink';
import infoImage from './images/step5_screenshot_paypal@2x.png';


const GuideThemePage = (props) => {
  const { changePage, infoIcon, routes } = props;

  return div({ className: 'container' }, [
    r(GuideBackToTodoLink, { changePage, routes }),
    h2({ className: css.title }, t('web.admin.onboarding.guide.theme.title')),
    p({ className: css.description }, [
      t('web.admin.onboarding.guide.theme.description'),
    ]),

    div({ className: css.sloganImageContainer }, [
      img({
        className: css.sloganImage,
        src: infoImage,
        alt: t('web.admin.onboarding.guide.theme.info_image_alt'),
      }),
    ]),

    div(null, [
        a({ className: css.nextButton, href: routes.admin_themes_path() }, t('web.admin.onboarding.guide.theme.select_theme')),
        span({ className: css.buttonSeparator }, t('web.admin.onboarding.guide.payments.cta_separator')),
        a({ className: css.nextButtonGhost, href: routes.admin_getting_started_guide_skip_theme_path() }, t('web.admin.onboarding.guide.next_step.skip_this_step_for_now')),
      ]),
  ]);
};

const { func, string, shape } = PropTypes;

GuideThemePage.propTypes = {
  changePage: func.isRequired,
  infoIcon: string.isRequired,
  routes: shape({
    admin_themes_path: func.isRequired,
    admin_getting_started_guide_skip_theme_path: func.isRequired
  }).isRequired,
};

export default GuideThemePage;
