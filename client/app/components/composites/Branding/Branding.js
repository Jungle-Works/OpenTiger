import { PropTypes } from 'react';
import { div, p, a } from 'r-dom';

import { t } from '../../../utils/i18n';

import css from './Branding.css';

export default function Branding({ linkToSharetribe }) {
  const learnMoreLink = a({ href: linkToSharetribe }, t('web.branding.learn_more'));
  const sharetribeLink = a({ href: linkToSharetribe }, 'Yelo');

  return div({
    className: css.brandingContainer,
  }, [
    div({
      className: css.brandingContent,
    }, [
      p({}, t('web.branding.powered_by', { service_name: 'Yelo', sharetribe_link: sharetribeLink, learn_more: learnMoreLink })),
      p({}, t('web.branding.create_own', { service_name: 'Yelo', learn_more: learnMoreLink })),
    ]),
  ]);
}

Branding.propTypes = {
  linkToSharetribe: PropTypes.string.isRequired,
};
